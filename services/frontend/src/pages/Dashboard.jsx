import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { userService } from '../services/api';
import BurgerMenu from '../components/BurgerMenu';
import ChangePasswordModal from '../components/ChangePasswordModal';
import '../styles/Dashboard.css';

const Dashboard = () => {
  const { user, logout, isAdmin, mustChangePassword, clearMustChangePassword } = useAuth();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (isAdmin()) {
      loadUsers();
    }
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await userService.getUsers();
      setUsers(data);
    } catch (err) {
      setError('Erreur lors du chargement des utilisateurs');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    logout();
    window.location.href = '/login';
  };

  const handlePasswordChanged = () => {
    clearMustChangePassword();
  };

  return (
    <div className="dashboard-container">
      <BurgerMenu />
      {mustChangePassword && (
        <ChangePasswordModal
          mustChange={true}
          onPasswordChanged={handlePasswordChanged}
        />
      )}
      <header className="dashboard-header">
        <div className="header-content">
          <h1>📊 Tableau de bord</h1>
          <button onClick={handleLogout} className="btn btn-secondary">
            Déconnexion
          </button>
        </div>
      </header>

      <div className="dashboard-content">
        {/* Carte de profil utilisateur */}
        <div className="card profile-card">
          <h2>👤 Profil Utilisateur</h2>
          <div className="profile-info">
            <div className="info-row">
              <span className="label">Nom d'utilisateur:</span>
              <span className="value">{user?.username}</span>
            </div>
            <div className="info-row">
              <span className="label">Email:</span>
              <span className="value">{user?.email}</span>
            </div>
            <div className="info-row">
              <span className="label">Prénom:</span>
              <span className="value">{user?.firstName || 'Non renseigné'}</span>
            </div>
            <div className="info-row">
              <span className="label">Nom:</span>
              <span className="value">{user?.lastName || 'Non renseigné'}</span>
            </div>
            <div className="info-row">
              <span className="label">Rôles:</span>
              <span className="value">
                {user?.roles?.map(role => (
                  <span key={role} className={`badge badge-${role}`}>
                    {role}
                  </span>
                ))}
              </span>
            </div>
          </div>
        </div>

        {/* Liste des utilisateurs (admin uniquement) */}
        {isAdmin() && (
          <div className="card users-card">
            <h2>👥 Gestion des Utilisateurs</h2>
            {error && (
              <div className="alert alert-error">
                {error}
              </div>
            )}
            {loading ? (
              <div className="loading">Chargement des utilisateurs...</div>
            ) : (
              <div className="users-table">
                <table>
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Prénom</th>
                      <th>Nom</th>
                      <th>Email</th>
                      <th>Date de création</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.length === 0 ? (
                      <tr>
                        <td colSpan="5" className="no-data">
                          Aucun utilisateur trouvé
                        </td>
                      </tr>
                    ) : (
                      users.map((u) => (
                        <tr key={u.id}>
                          <td>{u.id}</td>
                          <td>{u.firstName}</td>
                          <td>{u.lastName}</td>
                          <td>{u.email}</td>
                          <td>{new Date(u.createdAt).toLocaleDateString()}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* Informations sur les rôles */}
        <div className="card roles-info">
          <h2>ℹ️ Informations sur les Rôles</h2>
          <div className="role-description">
            <div className="role-item">
              <span className="badge badge-admin">admin</span>
              <p>Accès complet à toutes les fonctionnalités</p>
            </div>
            <div className="role-item">
              <span className="badge badge-manager">manager</span>
              <p>Accès étendu avec droits de gestion</p>
            </div>
            <div className="role-item">
              <span className="badge badge-user">user</span>
              <p>Accès standard aux fonctionnalités de base</p>
            </div>
            <div className="role-item">
              <span className="badge badge-guest">guest</span>
              <p>Accès limité en lecture seule</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
