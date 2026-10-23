# AZ Store API

Java 21, Spring Boot, PostgreSQL, Flyway. `mvn verify` exécute les tests
d’intégration. Le profil local utilise H2 ; aucun produit ni stock fictif n’est
créé automatiquement.

Le catalogue est public. Créer une commande et consulter son historique
nécessitent un compte. Chaque commande conserve sa devise et les prix de ses
articles. L’API vérifie les montants, les variantes et les droits du propriétaire.
Les confirmations décrémentent le stock ; une annulation autorisée le restitue.
Les modifications du catalogue utilisent un contrôle de version.

En production, `EXCHANGE_ENABLED=true` convertit automatiquement le prix MAD
vers XOF, arrondi au franc. Le taux indicatif ExchangeRate-API est mémorisé en
base et actualisé quotidiennement. Une panne conserve le dernier taux connu ;
aucun taux arbitraire n’est ajouté. Les commandes déjà enregistrées ne changent pas.

Une fiche `reference_only` reste visible et ne peut pas être commandée, même
si un stock est saisi. L’admin doit valider le prix réel, les images et les
quantités, puis désactiver ce mode pour vendre l’article.

Déploiement : `deploy/compose.yml`, services et volumes isolés sous `/opt/azstore`.
Le compte `deploy-azstore` possède deux clés à commandes forcées, limitées aux
commits de `main`. GitHub Actions teste avant de déployer. Les clés privées sont
conservées dans les secrets Actions, jamais dans le dépôt. Une vérification de
santé restaure l’image précédente si le déploiement échoue.

La récupération de mot de passe nécessite `MAIL_ENABLED=true`, `MAIL_FROM`
et les variables SMTP. Elle reste explicitement désactivée tant qu’aucun service
d’envoi n’est configuré. Paiement en ligne non activé ; finalisation WhatsApp.
