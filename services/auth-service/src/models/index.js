const User = require('./User');
const Role = require('./Role');

// Relation Many-to-Many entre User et Role
User.belongsToMany(Role, {
  through: 'UserRoles',
  foreignKey: 'userId',
  otherKey: 'roleId',
  as: 'roles'
});

Role.belongsToMany(User, {
  through: 'UserRoles',
  foreignKey: 'roleId',
  otherKey: 'userId',
  as: 'users'
});

module.exports = {
  User,
  Role
};
