const crypto = require('node:crypto');
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const {
  listProducts,
  getProductById,
  findUserByEmail,
  findUserById,
  createUser,
  createOrder,
  listOrdersByUser,
  getOrderById,
  getOrderByIdForAdmin,
  updateOrder,
} = require('./data');

const app = express();
const port = Number(process.env.PORT) || 3000;
const jwtSecret = process.env.JWT_SECRET || crypto.randomBytes(32).toString('hex');

app.use(cors());
app.use(express.json());

function asyncHandler(handler) {
  return (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);
}

function requireAdmin(req, res, next) {
  const adminApiKey = process.env.ADMIN_API_KEY;
  if (!adminApiKey) {
    return res.status(503).json({ message: 'Akses admin belum dikonfigurasi.' });
  }

  const providedKey = req.get('x-admin-key') || '';
  const expected = Buffer.from(adminApiKey);
  const provided = Buffer.from(providedKey);
  if (expected.length !== provided.length || !crypto.timingSafeEqual(expected, provided)) {
    return res.status(401).json({ message: 'Akses admin tidak valid.' });
  }
  return next();
}

function requireAuth(req, res, next) {
  const authorization = req.get('authorization') || '';
  const [scheme, token] = authorization.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Silakan login terlebih dahulu.' });
  }

  try {
    const payload = jwt.verify(token, jwtSecret);
    const user = findUserById(payload.sub);
    if (!user) {
      return res.status(401).json({ message: 'Sesi tidak valid. Silakan login kembali.' });
    }
    req.user = user;
    return next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError || error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({ message: 'Sesi tidak valid atau sudah berakhir.' });
    }
    return next(error);
  }
}

function publicUser(user) {
  return { id: user.id, name: user.name, email: user.email };
}

function signInResponse(user) {
  return {
    token: jwt.sign({ sub: user.id }, jwtSecret, { expiresIn: '7d' }),
    user: publicUser(user),
  };
}

app.post('/api/register', asyncHandler(async (req, res) => {
  const { name, email, password } = req.body || {};
  if (typeof name !== 'string' || name.trim().length < 2
      || typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
      || typeof password !== 'string' || password.length < 6) {
    return res.status(400).json({
      message: 'Nama minimal 2 karakter, email harus valid, dan password minimal 6 karakter.',
    });
  }
  if (findUserByEmail(email)) {
    return res.status(409).json({ message: 'Email sudah terdaftar.' });
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const user = createUser({ name, email, password: hashedPassword });
  return res.status(201).json({ message: 'Akun berhasil dibuat.', data: signInResponse(user) });
}));

app.post('/api/login', asyncHandler(async (req, res) => {
  const { email, password } = req.body || {};
  if (typeof email !== 'string' || typeof password !== 'string') {
    return res.status(400).json({ message: 'Email dan password wajib diisi.' });
  }
  const user = findUserByEmail(email);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ message: 'Email atau password salah.' });
  }
  return res.json({ message: 'Login berhasil.', data: signInResponse(user) });
}));

app.get('/api/me', requireAuth, (req, res) => {
  res.json({ data: publicUser(req.user) });
});

app.get('/api/products', (req, res) => {
  res.json({ data: listProducts({ search: req.query.search, kategori: req.query.kategori }) });
});

app.get('/api/products/:id', (req, res) => {
  const product = getProductById(req.params.id);
  if (!product) {
    return res.status(404).json({ message: 'Produk tidak ditemukan.' });
  }
  return res.json({ data: product });
});

app.post('/api/orders', requireAuth, (req, res) => {
  const { items, address, phone, notes = '' } = req.body || {};
  if (!Array.isArray(items) || items.length === 0
      || typeof address !== 'string' || address.trim().length < 5
      || typeof phone !== 'string' || phone.trim().length < 6
      || typeof notes !== 'string') {
    return res.status(400).json({ message: 'Item pesanan, alamat, dan nomor telepon harus valid.' });
  }

  const validatedItems = [];
  for (const item of items) {
    const product = item && getProductById(item.productId);
    const quantity = Number(item && item.quantity);
    if (!product || !Number.isInteger(quantity) || quantity < 1 || quantity > product.stock) {
      return res.status(400).json({ message: 'Produk atau jumlah item pesanan tidak valid.' });
    }
    validatedItems.push({ product, quantity });
  }

  const order = createOrder({
    userId: req.user.id,
    items: validatedItems,
    address,
    phone,
    notes,
  });
  return res.status(201).json({ message: 'Pesanan berhasil dibuat.', data: order });
});

app.get('/api/orders', requireAuth, (req, res) => {
  res.json({ data: listOrdersByUser(req.user.id) });
});

app.patch('/api/orders/:id/received', requireAuth, (req, res) => {
  const order = getOrderById(req.params.id, req.user.id);
  if (!order) {
    return res.status(404).json({ message: 'Pesanan tidak ditemukan.' });
  }
  if (order.status !== 'Dikirim') {
    return res.status(409).json({ message: 'Pesanan belum berstatus Dikirim.' });
  }

  const updatedOrder = updateOrder(order.id, { status: 'Diterima' });
  return res.json({ message: 'Pesanan ditandai telah diterima.', data: updatedOrder });
});

app.patch('/api/admin/orders/:id/status', requireAdmin, (req, res) => {
  const order = getOrderByIdForAdmin(req.params.id);
  if (!order) {
    return res.status(404).json({ message: 'Pesanan tidak ditemukan.' });
  }
  if (req.body?.status !== 'Dikirim') {
    return res.status(400).json({ message: 'Status admin yang diizinkan adalah Dikirim.' });
  }
  if (order.status !== 'Diproses') {
    return res.status(409).json({ message: 'Hanya pesanan Diproses yang dapat dikirim.' });
  }

  const updatedOrder = updateOrder(order.id, { status: 'Dikirim' });
  return res.json({ message: 'Status pesanan diperbarui menjadi Dikirim.', data: updatedOrder });
});

app.get('/api/orders/:id', requireAuth, (req, res) => {
  const order = getOrderById(req.params.id, req.user.id);
  if (!order) {
    return res.status(404).json({ message: 'Pesanan tidak ditemukan.' });
  }
  return res.json({ data: order });
});

app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint tidak ditemukan.' });
});

app.use((error, req, res, next) => {
  if (res.headersSent) {
    return next(error);
  }
  console.error(error);
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({ message: 'Format JSON tidak valid.' });
  }
  return res.status(500).json({ message: 'Terjadi kesalahan pada server.' });
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Toko Online API berjalan di http://localhost:${port}`);
  });
}

module.exports = app;