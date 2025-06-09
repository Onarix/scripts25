import React, { useEffect, useState } from 'react';
import { api } from './api';

export default function App() {
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);

  useEffect(() => {
    api.get('/products').then(res => setProducts(res.data));
  }, []);

  const addToCart = (product) => {
    setCart([...cart, product]);
  };

  const pay = () => {
    const total = cart.reduce((sum, p) => sum + p.price, 0);
    const user_id = 'user_' + Math.random().toString(36).substr(2, 6); // losowy ID

    api.post('/transactions', { user_id, total })
      .then(res => {
        alert(`Płatność udana! ID transakcji: ${res.data.id}`);
        setCart([]);
      })
      .catch(err => {
        alert('Błąd przy płatności!');
        console.error(err);
      });
  };

  return (
    <div>
      <h1>Sklep</h1>
      <h2>Produkty</h2>
      {products.map(p => (
        <div key={p.id}>
          {p.name} - {p.price} zł
          <button onClick={() => addToCart(p)}>Dodaj do koszyka</button>
        </div>
      ))}
      <h2>Koszyk ({cart.length})</h2>
      <ul>
        {cart.map((item, index) => (
          <li key={index}>{item.name} - {item.price} zł</li>
        ))}
      </ul>
      {cart.length > 0 && <button onClick={pay}>Zapłać</button>}
    </div>
  );
}
