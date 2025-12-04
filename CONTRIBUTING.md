# Guide de Contribution

Merci de votre intérêt pour contribuer au projet SuiviPro RATP !

## Code de Conduite

En participant à ce projet, vous acceptez de respecter notre code de conduite.

## Comment contribuer

### Rapporter un bug

1. Vérifiez que le bug n'a pas déjà été signalé dans les Issues
2. Créez une nouvelle Issue avec le label "bug"
3. Décrivez le bug de manière détaillée :
   - Étapes pour reproduire
   - Comportement attendu
   - Comportement actuel
   - Captures d'écran si applicable
   - Environnement (OS, version, etc.)

### Proposer une fonctionnalité

1. Créez une Issue avec le label "enhancement"
2. Décrivez la fonctionnalité souhaitée
3. Expliquez pourquoi elle serait utile
4. Proposez une implémentation si possible

### Soumettre une Pull Request

1. Fork le projet
2. Créez une branche depuis `develop` :
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```
3. Faites vos modifications en suivant les standards de code
4. Ajoutez des tests si nécessaire
5. Commitez vos changements :
   ```bash
   git commit -m "feat: ajout de ma fonctionnalité"
   ```
6. Poussez vers votre fork :
   ```bash
   git push origin feature/ma-fonctionnalite
   ```
7. Ouvrez une Pull Request vers `develop`

## Standards de code

### Commits

Nous utilisons [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types autorisés :
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation
- `style`: Formatage du code
- `refactor`: Refactoring
- `test`: Ajout/modification de tests
- `chore`: Tâches de maintenance

Exemples :
```
feat(auth): ajout de l'authentification 2FA
fix(user): correction du bug de validation email
docs(readme): mise à jour de la documentation d'installation
```

### Code Java

- Suivre le [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- Utiliser Lombok pour réduire le boilerplate
- Documenter les méthodes publiques avec JavaDoc
- Écrire des tests unitaires (minimum 80% de couverture)

### Code JavaScript/React

- Suivre le [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Utiliser des functional components et hooks
- Préférer la composition à l'héritage
- Écrire des tests avec React Testing Library

### Nommage

#### Java
```java
// Classes : PascalCase
public class UserService {}

// Méthodes : camelCase
public void getUserById(Long id) {}

// Constantes : UPPER_SNAKE_CASE
public static final String API_VERSION = "v1";
```

#### JavaScript
```javascript
// Variables et fonctions : camelCase
const userName = 'John';
function getUserData() {}

// Classes et composants : PascalCase
class UserService {}
const UserCard = () => {};

// Constantes : UPPER_SNAKE_CASE
const API_BASE_URL = 'http://api.example.com';
```

## Tests

### Backend (Java)

```bash
cd services/backend/[service-name]
mvn test
```

### Frontend

```bash
cd services/frontend
npm test
```

### Intégration

```bash
cd tests/integration
npm test
```

## Documentation

- Documentez toute nouvelle fonctionnalité dans `/docs`
- Mettez à jour le README si nécessaire
- Ajoutez des exemples d'utilisation
- Documentez les endpoints API dans `/docs/api`

## Review Process

1. Au moins un reviewer doit approuver
2. Tous les tests doivent passer
3. Pas de conflits avec la branche de destination
4. Le code doit respecter les standards

## Questions

Si vous avez des questions, n'hésitez pas à :
- Ouvrir une Discussion sur GitHub
- Contacter l'équipe technique

Merci pour votre contribution ! 🚀
