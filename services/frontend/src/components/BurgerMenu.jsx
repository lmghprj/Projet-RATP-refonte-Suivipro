import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import '../styles/BurgerMenu.css';

const BurgerMenu = () => {
  const [isOpen, setIsOpen] = useState(false);
  const { user, logout, isAdmin } = useAuth();

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  const closeMenu = () => {
    setIsOpen(false);
  };

  const handleLogout = () => {
    logout();
    closeMenu();
    window.location.href = '/login';
  };

  return (
    <>
      {/* Bouton burger */}
      <button
        className={`burger-button ${isOpen ? 'open' : ''}`}
        onClick={toggleMenu}
        aria-label="Menu"
      >
        <span></span>
        <span></span>
        <span></span>
      </button>

      {/* Overlay pour fermer le menu en cliquant à l'extérieur */}
      {isOpen && <div className="menu-overlay" onClick={closeMenu}></div>}

      {/* Menu latéral */}
      <nav className={`burger-menu ${isOpen ? 'open' : ''}`}>
        <div className="menu-header">
          <div className="user-info">
            <div className="user-avatar">
              {user?.firstName?.charAt(0) || user?.username?.charAt(0) || 'U'}
            </div>
            <div className="user-details">
              <p className="user-name">{user?.firstName} {user?.lastName}</p>
              <p className="user-email">{user?.email}</p>
            </div>
          </div>
        </div>

        <div className="menu-items">
          <Link to="/dashboard" className="menu-item" onClick={closeMenu}>
            <span className="menu-icon">📊</span>
            <span>Tableau de bord</span>
          </Link>

          {isAdmin() && (
            <>
              <Link to="/settings" className="menu-item" onClick={closeMenu}>
                <span className="menu-icon">⚙️</span>
                <span>Paramètres</span>
              </Link>

              <Link to="/permissions" className="menu-item" onClick={closeMenu}>
                <span className="menu-icon">🔐</span>
                <span>Permissions</span>
              </Link>
            </>
          )}

          <Link to="/profile" className="menu-item" onClick={closeMenu}>
            <span className="menu-icon">👤</span>
            <span>Mon profil</span>
          </Link>

          <div className="menu-divider"></div>

          <button className="menu-item logout" onClick={handleLogout}>
            <span className="menu-icon">🚪</span>
            <span>Déconnexion</span>
          </button>
        </div>

        <div className="menu-footer">
          <p>Version 1.0.0</p>
        </div>
      </nav>
    </>
  );
};

export default BurgerMenu;
