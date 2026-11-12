const products = [
  {
    id: 'p1',
    name: 'Tas Selempang Kanvas',
    description: 'Tas kasual berbahan kanvas tebal dengan ruang penyimpanan yang praktis.',
    price: 129000,
    category: 'Aksesori',
    image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
    stock: 18,
  },
  {
    id: 'p2',
    name: 'Headphone Nirkabel',
    description: 'Headphone nyaman dengan suara jernih untuk menemani aktivitas harian.',
    price: 349000,
    category: 'Elektronik',
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
    stock: 12,
  },
  {
    id: 'p3',
    name: 'Sneakers Urban',
    description: 'Sneakers ringan bergaya minimalis untuk penggunaan sehari-hari.',
    price: 459000,
    category: 'Fashion',
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
    stock: 9,
  },
  {
    id: 'p4',
    name: 'Botol Minum Stainless',
    description: 'Botol minum tahan panas dan dingin yang mudah dibawa bepergian.',
    price: 89000,
    category: 'Rumah Tangga',
    image: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
    stock: 25,
  },
  {
    id: 'p5',
    name: 'Jam Tangan Klasik',
    description: 'Jam tangan dengan desain klasik dan strap yang nyaman di pergelangan.',
    price: 279000,
    category: 'Aksesori',
    image: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=800&q=80',
    stock: 7,
  },
  {
    id: 'p6',
    name: 'Lampu Meja Minimalis',
    description: 'Lampu meja elegan dengan cahaya hangat untuk ruang kerja atau kamar.',
    price: 199000,
    category: 'Rumah Tangga',
    image: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
    stock: 14,
  },
];

const users = [];
const orders = [];

function createProduct(product) {
  const created = { ...product, id: String(product.id || `p${Date.now()}`) };
  products.push(created);
  return created;
}

function listProducts({ search = '', kategori = '' } = {}) {
  const query = String(search).trim().toLowerCase();
  const category = String(kategori).trim().toLowerCase();
  return products.filter((product) => {
    const matchesSearch = !query
      || product.name.toLowerCase().includes(query)
      || product.description.toLowerCase().includes(query);
    const matchesCategory = !category || product.category.toLowerCase() === category;
    return matchesSearch && matchesCategory;
  });
}

function getProductById(id) {
  return products.find((product) => product.id === String(id)) || null;
}

function updateProduct(id, updates) {
  const product = getProductById(id);
  if (!product) return null;
  Object.assign(product, updates, { id: product.id });
  return product;
}

function deleteProduct(id) {
  const index = products.findIndex((product) => product.id === String(id));
  return index < 0 ? null : products.splice(index, 1)[0];
}

function findUserByEmail(email) {
  return users.find((user) => user.email === String(email).trim().toLowerCase()) || null;
}

function findUserById(id) {
  return users.find((user) => user.id === String(id)) || null;
}

function updateUser(id, updates) {
  const user = findUserById(id);
  if (!user) return null;
  Object.assign(user, updates, { id: user.id });
  if (typeof user.email === 'string') user.email = user.email.trim().toLowerCase();
  return user;
}

function deleteUser(id) {
  const index = users.findIndex((user) => user.id === String(id));
  return index < 0 ? null : users.splice(index, 1)[0];
}

function createUser({ name, email, password }) {
  const user = {
    id: `u${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
    name: String(name).trim(),
    email: String(email).trim().toLowerCase(),
    password,
    createdAt: new Date().toISOString(),
  };
  users.push(user);
  return user;
}

function createOrder({ userId, items, address, phone, notes = '' }) {
  const order = {
    id: `o${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
    userId: String(userId),
    items: items.map(({ product, quantity }) => ({
      productId: product.id,
      name: product.name,
      price: product.price,
      quantity,
      image: product.image,
    })),
    total: items.reduce((sum, { product, quantity }) => sum + product.price * quantity, 0),
    address: String(address).trim(),
    phone: String(phone).trim(),
    notes: String(notes).trim(),
    status: 'Diproses',
    createdAt: new Date().toISOString(),
  };
  orders.push(order);
  return order;
}

function listOrdersByUser(userId) {
  return orders
    .filter((order) => order.userId === String(userId))
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

function getOrderById(id, userId) {
  return orders.find((order) => order.id === String(id) && order.userId === String(userId)) || null;
}

function getOrderByIdForAdmin(id) {
  return orders.find((order) => order.id === String(id)) || null;
}

function updateOrder(id, updates) {
  const order = orders.find((item) => item.id === String(id));
  if (!order) return null;
  Object.assign(order, updates, { id: order.id, userId: order.userId });
  return order;
}

function deleteOrder(id) {
  const index = orders.findIndex((order) => order.id === String(id));
  return index < 0 ? null : orders.splice(index, 1)[0];
}

module.exports = {
  products,
  users,
  orders,
  createProduct,
  listProducts,
  getProductById,
  updateProduct,
  deleteProduct,
  findUserByEmail,
  findUserById,
  updateUser,
  deleteUser,
  createUser,
  createOrder,
  listOrdersByUser,
  getOrderById,
  getOrderByIdForAdmin,
  updateOrder,
  deleteOrder,
};