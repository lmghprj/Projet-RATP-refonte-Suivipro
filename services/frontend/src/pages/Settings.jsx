import { useState, useEffect } from 'react';
import { adminService } from '../services/api';
import '../styles/Settings.css';

const Settings = () => {
  const [users, setUsers] = useState([]);
  const [roles, setRoles] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Formulaire de création d'utilisateur
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    firstName: '',
    lastName: '',
    roleNames: ['user']
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [usersData, rolesData] = await Promise.all([
        adminService.getAllUsers(),
        adminService.getAllRoles()
      ]);

      setUsers(usersData.users || []);
      setRoles(rolesData.roles || []);
    } catch (err) {
      setError('Erreur lors du chargement des données');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleRoleChange = (e) => {
    const selectedRoles = Array.from(e.target.selectedOptions, option => option.value);
    setFormData(prev => ({
      ...prev,
      roleNames: selectedRoles
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    try {
      setLoading(true);
      const result = await adminService.createUser(formData);

      setSuccess(
        `Utilisateur créé avec succès ! ${
          result.emailSent
            ? 'Un email a été envoyé avec les identifiants.'
            : 'Attention: L\'email n\'a pas pu être envoyé.'
        }`
      );

      // Réinitialiser le formulaire
      setFormData({
        username: '',
        email: '',
        firstName: '',
        lastName: '',
        roleNames: ['user']
      });

      // Recharger la liste des utilisateurs
      await loadData();
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de la création de l\'utilisateur');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (userId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
      return;
    }

    try {
      setLoading(true);
      await adminService.deleteUser(userId);
      setSuccess('Utilisateur supprimé avec succès');
      await loadData();
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de la suppression');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="settings-container">
      <h1>⚙️ Paramètres - Gestion des Utilisateurs</h1>

      {error && (
        <div className="alert alert-error">
          {error}
          <button onClick={() => setError('')}>×</button>
        </div>
      )}

      {success && (
        <div className="alert alert-success">
          {success}
          <button onClick={() => setSuccess('')}>×</button>
        </div>
      )}

      <div className="settings-content">
        {/* Formulaire de création d'utilisateur */}
        <div className="card">
          <h2>Créer un nouvel utilisateur</h2>
          <form onSubmit={handleSubmit} className="create-user-form">
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="username">Nom d'utilisateur *</label>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={formData.username}
                  onChange={handleInputChange}
                  placeholder="johndoe"
                  required
                  disabled={loading}
                  minLength={3}
                  maxLength={50}
                  pattern="[a-zA-Z0-9_]+"
                  title="Lettres, chiffres et underscores uniquement"
                />
              </div>

              <div className="form-group">
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  placeholder="john.doe@example.com"
                  required
                  disabled={loading}
                />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="firstName">Prénom</label>
                <input
                  type="text"
                  id="firstName"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleInputChange}
                  placeholder="John"
                  disabled={loading}
                  maxLength={100}
                />
              </div>

              <div className="form-group">
                <label htmlFor="lastName">Nom</label>
                <input
                  type="text"
                  id="lastName"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleInputChange}
                  placeholder="Doe"
                  disabled={loading}
                  maxLength={100}
                />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="roles">Rôles *</label>
              <select
                id="roles"
                multiple
                value={formData.roleNames}
                onChange={handleRoleChange}
                disabled={loading}
                size={4}
              >
                {roles.map(role => (
                  <option key={role.id} value={role.name}>
                    {role.name} - {role.description}
                  </option>
                ))}
              </select>
              <small className="form-help">
                Maintenez Ctrl (Cmd sur Mac) pour sélectionner plusieurs rôles
              </small>
            </div>

            <div className="form-info">
              <p>ℹ️ Un mot de passe temporaire sera généré et envoyé par email à l'utilisateur.</p>
              <p>L'utilisateur devra changer son mot de passe à la première connexion.</p>
            </div>

            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Création en cours...' : 'Créer l\'utilisateur'}
            </button>
          </form>
        </div>

        {/* Liste des utilisateurs */}
        <div className="card">
          <h2>Utilisateurs existants ({users.length})</h2>
          {loading && users.length === 0 ? (
            <div className="loading">Chargement des utilisateurs...</div>
          ) : (
            <div className="users-table-container">
              <table className="users-table">
                <thead>
                  <tr>
                    <th>Utilisateur</th>
                    <th>Email</th>
                    <th>Nom complet</th>
                    <th>Rôles</th>
                    <th>Changement MDP requis</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map(user => (
                    <tr key={user.id}>
                      <td>{user.username}</td>
                      <td>{user.email}</td>
                      <td>{user.firstName} {user.lastName}</td>
                      <td>
                        {user.roles?.map(role => (
                          <span key={role.id} className={`badge badge-${role.name}`}>
                            {role.name}
                          </span>
                        ))}
                      </td>
                      <td>
                        {user.mustChangePassword ? (
                          <span className="badge badge-warning">Oui</span>
                        ) : (
                          <span className="badge badge-success">Non</span>
                        )}
                      </td>
                      <td>
                        <button
                          className="btn btn-sm btn-danger"
                          onClick={() => handleDeleteUser(user.id)}
                          disabled={loading}
                        >
                          Supprimer
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Settings;
