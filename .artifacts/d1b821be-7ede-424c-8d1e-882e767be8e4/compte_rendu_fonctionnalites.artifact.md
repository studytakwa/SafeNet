# Compte-Rendu Technique : Publications, Invitations et Liste d'Amis

Ce document présente le bilan technique des fonctionnalités clés implémentées dans l'application **SafeNet** : la gestion des publications (posts), le système d'invitations d'amis et la gestion de la liste d'amis.

---

## 1. Module Publications (Posts)

Le module de publications permet aux utilisateurs de partager du contenu textuel ou multimédia au sein de la communauté, tout en intégrant un flux de modération administrateur.

* **Création et Composition** :
  - Géré par `PostComposer` et `PostController`.
  - Permet la saisie de texte, l'ajout d'images (converties en base64 ou gérées via stockage) et la catégorisation par types (via `TypeBadge`).
* **Affichage du Fil d'Actualité (Feed)** :
  - `HomeFeed` et `PostList` écoutent en temps réel les publications validées via des `StreamBuilder` connectés à Cloud Firestore.
  - Chaque publication (`PostCard`) affiche l'avatar et le nom de l'auteur (`UserAvatar`, `UserName`), la date de création, le contenu et propose des actions interactives (J'aime, Commentaires via `CommentsSheet`).
* **Modération Administrateur** :
  - Les publications passent par un statut (`pending`, `approved`, `rejected`).
  - L'espace admin (`AdminPostsPage` / `AdminService`) permet d'accepter ou de refuser un post (avec un motif de refus optionnel) et notifie automatiquement l'auteur via la collection `notifications`.

---

## 2. Module Invitations d'Amis

Le système d'invitation repose sur une modélisation bidirectionnelle robuste des relations entre utilisateurs.

* **Modèle de Relation (`RelationModel` / `SocialController`)** :
  - Utilisation d'un identifiant unique de paire `pairId(uidA, uidB)` basé sur l'ordre alphabétique des UIDs pour garantir qu'il n'existe qu'un seul document de liaison entre deux utilisateurs, quel que soit l'initiateur.
  - États possibles de la relation : `none` (aucune), `sent` (demande envoyée), `received` (demande reçue), `friends` (amis).
* **Flux d'Invitation** :
  - **Envoi** : `envoyerDemande(other)` crée un document de relation avec le statut `pending` et génère une notification de type `friend_request`.
  - **Acceptation** : `accepter(other)` met à jour le statut à `friends` et envoie une notification `friend_accepted`.
  - **Refus / Annulation** : `retirer(other)` supprime le document de relation.
* **Centre de Notifications (`NotificationPage`)** :
  - Permet de visualiser et de répondre aux demandes d'amitié en temps réel.

---

## 3. Module Liste des Amis

Une fois l'invitation acceptée, les utilisateurs apparaissent dans leurs listes d'amis respectives.

* **Filtrage des Amis** :
  - `SocialController.idsAmis()` filtre les relations où `status == 'friends'` et extrait l'identifiant de l'autre utilisateur (`other(uid)`).
* **Affichage et Utilisation** :
  - `AmisPage` liste l'ensemble des amis connectés.
  - Le composant `FriendButton` gère dynamiquement l'affichage du bouton d'action contextuel (Ajouter, Annuler, Accepter, Retirer un ami) en fonction de l'état de la relation en temps réel.
