# 1. Gestion de l'état
- Bicep : Aucun backend à configurer ni risque de fichier d'état corrompu ou de verrou (state lock) bloqué en équipe. En revanche, la détection du drift dépend uniquement de l'état réel vu par ARM au moment du déploiement.

- Terraform : Le fichier .tfstate offre une détection du drift précise et suit les ressources supprimées en dehors du code. L'inconvénient réside dans la complexité de configuration du backend distant (Azure Blob Storage, gestion des verrous) et les risques de conflits à plusieurs.

# 2. Portabilité multi-cloud
- Déterminant : En contexte multi-cloud (Azure + AWS/GCP) ou hybride (infrastructure cloud + providers tiers comme Kubernetes, Helm ou Datadog) pour conserver un outil et un workflow uniques.

- Sans intérêt : Pour un projet hébergé à 100 % sur Azure qui s'appuie exclusivement sur des services managés Microsoft.

# 3. Support des nouveaux services Azure
- Bicep s'appuie directement sur les schémas d'API ARM, offrant un support Day One de toutes les nouveautés Azure. Le délai de mise à jour du provider Terraform azurerm devient un vrai problème quand il faut automatiser le déploiement d'une fonctionnalité fraîchement sortie.

# 4. Syntaxe et écosystème de modules
- Syntaxe : Bicep est plus rapide à écrire que HCL sur Azure. Sa syntaxe est plus concise, moins verbeuse.

- Écosystème : Terraform possède un Registry immensément plus vaste et mature.

# 5. Cycle provisioning/destruction en CI
- Le modèle Bicep est plus sûr dans une CI partagée. Cibler explicitement un groupe de ressources (az group delete --name rg-...) garantit un périmètre de destruction strictement isolé. Avec Terraform, une désynchronisation ou une mauvaise manipulation du fichier d'état partagé par un membre peut entraîner la suppression involontaire de ressources hors du scope prévu.