import { useState, useEffect } from 'react';
import { adminService } from '../services/api';
import '../styles/Permissions.css';

const Permissions = () => {
  const [roles, setRoles] = useState([]);
  const [selectedRole, setSelectedRole] = useState(null);
  const [permissions, setPermissions] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Liste des fonctionnalités disponibles
  const availableFunctions = [
    { key: 'users', label: 'Gestion des utilisateurs', actions: ['create', 'read', 'update', 'delete'] },
    { key: 'roles', label: 'Gestion des rôles', actions: ['create', 'read', 'update', 'delete'] },
    { key: 'permissions', label: 'Gestion des permissions', actions: ['read', 'update'] },
    { key: 'reports', label: 'Rapports', actions: ['read', 'create', 'export'] },
    { key: 'settings', label: 'Paramètres', actions: ['read', 'update'] },
    { key: 'profile', label: 'Profil', actions: ['read', 'update'] }
  ];

  useEffect(() => {
    loadRoles();
  }, []);

  const loadRoles = async () => {
    try {
      setLoading(true);
      const data = await adminService.getAllRoles();
      setRoles(data.roles || []);

      // Sélectionner le premier rôle par défaut
      if (data.roles && data.roles.length > 0) {
        selectRole(data.roles[0]);
      }
    } catch (err) {
      setError('Erreur lors du chargement des rôles');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const selectRole = (role) => {
    setSelectedRole(role);
    setPermissions(role.permissions || {});
  };

  const handlePermissionChange = (functionKey, action) => {
    setPermissions(prev => {
      const functionPerms = prev[functionKey] || [];
      const newPerms = functionPerms.includes(action)
        ? functionPerms.filter(a => a !== action)
        : [...functionPerms, action];

      return {
        ...prev,
        [functionKey]: newPerms
      };
    });
  };

  const handleSelectAll = (functionKey) => {
    const func = availableFunctions.find(f => f.key === functionKey);
    if (!func) return;

    setPermissions(prev => ({
      ...prev,
      [functionKey]: func.actions
    }));
  };

  const handleDeselectAll = (functionKey) => {
    setPermissions(prev => ({
      ...prev,
      [functionKey]: []
    }));
  };

  const handleSave = async () => {
    if (!selectedRole) return;

    try {
      setLoading(true);
      setError('');
      setSuccess('');

      await adminService.updateRolePermissions(selectedRole.id, permissions);
      setSuccess('Permissions mises à jour avec succès');

      // Recharger les rôles
      await loadRoles();
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de la mise à jour des permissions');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="permissions-container">
      <h1>🔐 Gestion des Permissions</h1>

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

      <div className="permissions-content">
        {/* Sélection du rôle */}
        <div className="card roles-selector">
          <h2>Sélectionner un rôle</h2>
          <div className="roles-list">
            {roles.map(role => (
              <button
                key={role.id}
                className={`role-button ${selectedRole?.id === role.id ? 'active' : ''}`}
                onClick={() => selectRole(role)}
                disabled={loading}
              >
                <span className={`badge badge-${role.name}`}>{role.name}</span>
                <p>{role.description}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Gestion des permissions */}
        {selectedRole && (
          <div className="card permissions-editor">
            <div className="card-header">
              <h2>
                Permissions pour le rôle: <span className={`badge badge-${selectedRole.name}`}>{selectedRole.name}</span>
              </h2>
              <p>{selectedRole.description}</p>
            </div>

            <div className="permissions-grid">
              {availableFunctions.map(func => (
                <div key={func.key} className="permission-section">
                  <div className="permission-header">
                    <h3>{func.label}</h3>
                    <div className="permission-controls">
                      <button
                        className="btn btn-sm"
                        onClick={() => handleSelectAll(func.key)}
                        disabled={loading}
                      >
                        Tout sélectionner
                      </button>
                      <button
                        className="btn btn-sm"
                        onClick={() => handleDeselectAll(func.key)}
                        disabled={loading}
                      >
                        Tout désélectionner
                      </button>
                    </div>
                  </div>

                  <div className="permission-actions">
                    {func.actions.map(action => {
                      const isChecked = (permissions[func.key] || []).includes(action);
                      return (
                        <label key={action} className="checkbox-label">
                          <input
                            type="checkbox"
                            checked={isChecked}
                            onChange={() => handlePermissionChange(func.key, action)}
                            disabled={loading}
                          />
                          <span className="action-label">{action}</span>
                        </label>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>

            <div className="permissions-actions">
              <button
                className="btn btn-primary"
                onClick={handleSave}
                disabled={loading}
              >
                {loading ? 'Sauvegarde en cours...' : 'Enregistrer les permissions'}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Permissions;
