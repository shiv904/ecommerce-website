/* ShopSmart — E‑commerce Frontend JS */
(function () {
  const CURRENCY = 'USD';
  const LS_CART_KEY = 'shopsmart_cart_v1';

  /** ---- Data ---- */
  const products = [
    { id: 1, title: 'Classic Tee', price: 19.99, category: 'Apparel', rating: 4.4, image: img(1), description: 'Soft cotton tee with classic fit and durable stitching.' },
    { id: 2, title: 'Performance Sneakers', price: 79.0, category: 'Footwear', rating: 4.7, image: img(2), description: 'Lightweight running shoes designed for speed and comfort.' },
    { id: 3, title: 'Wireless Headphones', price: 119.0, category: 'Electronics', rating: 4.6, image: img(3), description: 'Noise-cancelling headphones with 30 hours of battery life.' },
    { id: 4, title: 'Ceramic Mug', price: 14.5, category: 'Home', rating: 4.2, image: img(4), description: 'Hand-glazed ceramic mug perfect for coffee or tea.' },
    { id: 5, title: 'Yoga Mat', price: 29.99, category: 'Fitness', rating: 4.5, image: img(5), description: 'Non-slip yoga mat with excellent cushioning and grip.' },
    { id: 6, title: 'Smartwatch', price: 199, category: 'Electronics', rating: 4.3, image: img(6), description: 'Track fitness, sleep, and notifications with a sleek smartwatch.' },
    { id: 7, title: 'Denim Jacket', price: 89.0, category: 'Apparel', rating: 4.1, image: img(7), description: 'Classic denim jacket with a modern cut and soft wash.' },
    { id: 8, title: 'Scented Candle', price: 18.0, category: 'Home', rating: 4.0, image: img(8), description: 'Slow-burning candle with notes of cedarwood and vanilla.' },
    { id: 9, title: 'Stainless Water Bottle', price: 24.0, category: 'Outdoors', rating: 4.8, image: img(9), description: 'Insulated bottle keeps drinks cold 24h, hot 12h.' },
    { id: 10, title: 'Bluetooth Speaker', price: 59.5, category: 'Electronics', rating: 4.4, image: img(10), description: 'Portable speaker with deep bass and water resistant body.' },
    { id: 11, title: 'Trail Backpack', price: 74.0, category: 'Outdoors', rating: 4.6, image: img(11), description: 'Ergonomic backpack with breathable mesh and ample storage.' },
    { id: 12, title: 'Lip Care Set', price: 15.0, category: 'Beauty', rating: 4.3, image: img(12), description: 'Hydrating balm and scrub for daily lip care.' }
  ];

  function img(seed) {
    return `https://picsum.photos/seed/p${seed}/800/800`;
  }

  /** ---- State ---- */
  const state = {
    searchText: '',
    category: 'all',
    sort: 'featured',
    cart: loadCart()
  };

  /** ---- Elements ---- */
  const el = {
    grid: document.getElementById('productsGrid'),
    search: document.getElementById('searchInput'),
    category: document.getElementById('categorySelect'),
    sort: document.getElementById('sortSelect'),
    cartBtn: document.getElementById('cartButton'),
    cartCount: document.getElementById('cartCount'),
    drawer: document.getElementById('cartDrawer'),
    drawerOverlay: document.getElementById('drawerOverlay'),
    drawerClose: document.getElementById('drawerClose'),
    cartItems: document.getElementById('cartItems'),
    cartSubtotal: document.getElementById('cartSubtotal'),
    checkoutBtn: document.getElementById('checkoutBtn'),
    modal: document.getElementById('productModal'),
    modalTitle: document.getElementById('modalTitle'),
    modalDesc: document.getElementById('modalDescription'),
    modalImg: document.getElementById('modalImage'),
    modalPrice: document.getElementById('modalPrice'),
    modalRating: document.getElementById('modalRating'),
    modalQty: document.getElementById('modalQty'),
    modalClose: document.getElementById('modalClose'),
    qtyDec: document.getElementById('qtyDec'),
    qtyInc: document.getElementById('qtyInc'),
    addToCartBtn: document.getElementById('addToCartBtn')
  };

  const idToProduct = new Map(products.map(p => [p.id, p]));

  /** ---- Init ---- */
  init();

  function init() {
    populateCategories();
    bindEvents();
    renderProducts();
    renderCart();
    const yearEl = document.getElementById('year');
    if (yearEl) yearEl.textContent = String(new Date().getFullYear());
  }

  function populateCategories() {
    const categories = Array.from(new Set(products.map(p => p.category))).sort();
    for (const cat of categories) {
      const opt = document.createElement('option');
      opt.value = cat;
      opt.textContent = cat;
      el.category.appendChild(opt);
    }
  }

  function bindEvents() {
    el.search.addEventListener('input', e => {
      state.searchText = e.target.value.trim();
      renderProducts();
    });
    el.category.addEventListener('change', e => {
      state.category = e.target.value;
      renderProducts();
    });
    el.sort.addEventListener('change', e => {
      state.sort = e.target.value;
      renderProducts();
    });

    el.cartBtn.addEventListener('click', () => toggleDrawer(true));
    el.drawerClose.addEventListener('click', () => toggleDrawer(false));
    el.drawerOverlay.addEventListener('click', () => toggleDrawer(false));

    // Modal
    el.modal.addEventListener('click', (e) => {
      if (e.target.dataset.closeModal === 'true') closeModal();
    });
    el.modalClose.addEventListener('click', closeModal);
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        if (!el.modal.hasAttribute('aria-hidden')) closeModal();
        if (!el.drawer.hasAttribute('hidden')) toggleDrawer(false);
      }
    });

    el.qtyDec.addEventListener('click', () => setQty(Math.max(1, (parseInt(el.modalQty.value || '1', 10) - 1))));
    el.qtyInc.addEventListener('click', () => setQty((parseInt(el.modalQty.value || '1', 10) + 1)));
    el.addToCartBtn.addEventListener('click', () => {
      const productId = parseInt(el.addToCartBtn.dataset.productId, 10);
      const qty = Math.max(1, parseInt(el.modalQty.value || '1', 10));
      addToCart(productId, qty);
      closeModal();
      toggleDrawer(true);
    });
  }

  function setQty(val) {
    el.modalQty.value = String(val);
  }

  /** ---- Rendering: Products ---- */
  function renderProducts() {
    const list = applySort(applyFilter(products));
    el.grid.innerHTML = '';
    if (list.length === 0) {
      const empty = document.createElement('div');
      empty.className = 'card';
      empty.innerHTML = `<div class="card-body"><strong>No products found</strong><p class="muted">Try adjusting search or filters.</p></div>`;
      el.grid.appendChild(empty);
      return;
    }
    const frag = document.createDocumentFragment();
    for (const p of list) frag.appendChild(productCard(p));
    el.grid.appendChild(frag);
  }

  function applyFilter(list) {
    const q = state.searchText.toLowerCase();
    const cat = state.category;
    return list.filter(p => {
      const matchesText = !q || p.title.toLowerCase().includes(q) || p.description.toLowerCase().includes(q);
      const matchesCat = cat === 'all' || p.category === cat;
      return matchesText && matchesCat;
    });
  }

  function applySort(list) {
    const arr = [...list];
    switch (state.sort) {
      case 'price-asc':
        arr.sort((a, b) => a.price - b.price); break;
      case 'price-desc':
        arr.sort((a, b) => b.price - a.price); break;
      case 'rating-desc':
        arr.sort((a, b) => b.rating - a.rating); break;
      default:
        // featured: stable as-is
        break;
    }
    return arr;
  }

  function productCard(p) {
    const card = document.createElement('article');
    card.className = 'card';
    card.innerHTML = `
      <div class="card-media">
        <img src="${p.image}" alt="${escapeHtml(p.title)}" loading="lazy" />
      </div>
      <div class="card-body">
        <div class="chip" aria-label="Category">${escapeHtml(p.category)}</div>
        <h3 class="card-title">${escapeHtml(p.title)}</h3>
        <p class="muted">${escapeHtml(p.description)}</p>
        <div class="price-row">
          <span class="price">${formatPrice(p.price)}</span>
          <span class="rating">★ ${p.rating.toFixed(1)}</span>
        </div>
      </div>
      <div class="card-actions">
        <button class="btn" data-action="quick-view" data-id="${p.id}">Quick view</button>
        <button class="btn btn-primary" data-action="add" data-id="${p.id}">Add to cart</button>
      </div>
    `;

    card.addEventListener('click', (e) => {
      const target = e.target;
      if (!(target instanceof HTMLElement)) return;
      const action = target.dataset.action;
      const id = parseInt(target.dataset.id || '0', 10);
      if (action === 'quick-view') {
        openModal(id);
      } else if (action === 'add') {
        addToCart(id, 1);
      }
    });
    return card;
  }

  /** ---- Modal ---- */
  function openModal(productId) {
    const p = idToProduct.get(productId);
    if (!p) return;
    el.addToCartBtn.dataset.productId = String(p.id);
    el.modalTitle.textContent = p.title;
    el.modalDesc.textContent = p.description;
    el.modalImg.src = p.image;
    el.modalImg.alt = p.title;
    el.modalPrice.textContent = formatPrice(p.price);
    el.modalRating.textContent = `★ ${p.rating.toFixed(1)}`;
    setQty(1);
    el.modal.removeAttribute('aria-hidden');
  }

  function closeModal() {
    el.modal.setAttribute('aria-hidden', 'true');
  }

  /** ---- Cart ---- */
  function addToCart(productId, qty) {
    const p = idToProduct.get(productId);
    if (!p) return;
    const curr = state.cart[productId] || { qty: 0, product: p };
    curr.qty += qty;
    state.cart[productId] = curr;
    persistCart();
    renderCart();
  }

  function updateQty(productId, qty) {
    const item = state.cart[productId];
    if (!item) return;
    item.qty = Math.max(1, qty);
    persistCart();
    renderCart();
  }

  function removeFromCart(productId) {
    delete state.cart[productId];
    persistCart();
    renderCart();
  }

  function renderCart() {
    const entries = Object.values(state.cart);
    el.cartItems.innerHTML = '';
    if (entries.length === 0) {
      const empty = document.createElement('p');
      empty.className = 'muted';
      empty.textContent = 'Your cart is empty.';
      el.cartItems.appendChild(empty);
      el.cartSubtotal.textContent = formatPrice(0);
      el.cartCount.textContent = '0';
      return;
    }

    let subtotal = 0;
    const frag = document.createDocumentFragment();
    for (const { product, qty } of entries) {
      subtotal += product.price * qty;
      frag.appendChild(cartRow(product, qty));
    }
    el.cartItems.appendChild(frag);
    el.cartSubtotal.textContent = formatPrice(subtotal);
    el.cartCount.textContent = String(entries.reduce((s, x) => s + x.qty, 0));
  }

  function cartRow(product, qty) {
    const row = document.createElement('div');
    row.className = 'cart-row';
    row.innerHTML = `
      <img src="${product.image}" alt="${escapeHtml(product.title)}" />
      <div>
        <div class="title">${escapeHtml(product.title)}</div>
        <div class="meta">${escapeHtml(product.category)}</div>
        <div class="qty" role="group" aria-label="Quantity">
          <button class="qty-btn" data-action="dec" aria-label="Decrease quantity">−</button>
          <input class="qty-input" type="number" min="1" value="${qty}" inputmode="numeric" />
          <button class="qty-btn" data-action="inc" aria-label="Increase quantity">+</button>
        </div>
      </div>
      <div>
        <div class="price">${formatPrice(product.price * qty)}</div>
        <div style="display:flex; gap:.4rem; margin-top:.35rem; justify-content:flex-end">
          <button class="btn" data-action="remove">Remove</button>
        </div>
      </div>
    `;

    const input = row.querySelector('.qty-input');
    const dec = row.querySelector('[data-action="dec"]');
    const inc = row.querySelector('[data-action="inc"]');
    const removeBtn = row.querySelector('[data-action="remove"]');

    dec.addEventListener('click', () => updateQty(product.id, Math.max(1, parseInt(input.value || '1', 10) - 1)));
    inc.addEventListener('click', () => updateQty(product.id, parseInt(input.value || '1', 10) + 1));
    input.addEventListener('change', () => updateQty(product.id, Math.max(1, parseInt(input.value || '1', 10))));
    removeBtn.addEventListener('click', () => removeFromCart(product.id));

    return row;
  }

  function toggleDrawer(open) {
    if (open) {
      el.drawer.removeAttribute('hidden');
      el.drawerOverlay.hidden = false;
    } else {
      el.drawer.setAttribute('hidden', '');
      el.drawerOverlay.hidden = true;
    }
  }

  function persistCart() {
    try { localStorage.setItem(LS_CART_KEY, JSON.stringify(state.cart)); } catch {}
  }
  function loadCart() {
    try {
      const raw = localStorage.getItem(LS_CART_KEY);
      return raw ? reviveCart(JSON.parse(raw)) : {};
    } catch {
      return {};
    }
  }
  function reviveCart(obj) {
    const revived = {};
    for (const [id, item] of Object.entries(obj)) {
      const product = idToProduct.get(Number(id));
      if (product) revived[id] = { product, qty: Number(item.qty) || 1 };
    }
    return revived;
  }

  /** ---- Utils ---- */
  function formatPrice(value) {
    return new Intl.NumberFormat(undefined, { style: 'currency', currency: CURRENCY }).format(value);
  }
  function escapeHtml(text) {
    return String(text).replace(/[&<>"]+/g, s => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[s]));
  }
})();

