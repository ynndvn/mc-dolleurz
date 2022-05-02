# MC-DOLLARZ

## I. Routes

### I.1. Gestion de comptes utilisateurs

#### I.1.a. Création d'utilisateur

Route: `POST /players/:uuid`

Body:

```json
{
  "nickname": string
}
```

L'UUID correspond à l'UUID fourni par Mojang si on y a accès. Le nickname sera le pseudo affiché pour les transactions.
Une vérif de duplication sera à faire avant l'insertion.
Crée l'objet utilisateur en base avec sa balance à 0.

#### I.1.b. Renommage d'utilisateur

Route: `PUT /players/:uuid/nickname/:nickname`

Route "cosmétique", l'opération retirera une certaine somme de la `balance` du joueur.

#### I.1.c. Récupération du solde utilisateur

Route: `GET /players/:uuid/balance`

Retourne la valeur de `balance` en base pour l'`uuid` passé en paramètre

#### I.1.d. Ajout à la balance utilisateur

Route: `POST /players/:uuid/balance/add`

Body:

```json
{
  "amount": number
}
```

Ajoute `amount` au compte utilisateur

#### I.1.e. Retirer à la balance utilisateur

Route: `POST /players/:uuid/balance/remove`

Body:

```json
{
  "amount": number
}
```

Retire `amount` du compte utilisateur

#### I.1.f. Récupération liste utilisateurs

Route: `GET /players`

Body:

```json
[
  {
    "userId": string,
    "nickname": string,
    "balance": number
  }
]
```

Retire `amount` du compte utilisateur

### I.2. Gestion des offres

#### I.2.a. Création d'offre

Route: `POST /offers/:itemname`

Body:

```json
{
  "price": number
}
```

À voir comment faire transiter le `itemname`, qui correspondra à l'ID dans le jeu.

#### I.2.b. Modification du prix d'une offre

Route: `PUT /offers/:itemname/price/:price`

#### I.2.c. Récupération des offres

Route: `GET /offers`

Réponse:

```json
[
  {
    "price": number,
    "name": string
  }
]
```

#### I.2.d. Achat d'une offre

Route: `POST /offers/:itemname/buy`

Body:

```json
{
  "quantity": number,
  "userId": string
}
```

Vérifie si le compte user a assez de dollarz en base avant d'accepter la transaction

#### I.2.e. Vente d'une offre

Route: `POST /offers/:itemname/sell`

Body:

```json
{
  "quantity": number,
  "userId": string
}
```

#### I.2.f. Suppression d'une offre

Route: `DELETE /offers/:itemname`

### I.3. Gestion des transactions entre joueurs

Route: `POST /transactions`

Body:

```json
{
  "from": string,
  "to": string,
  "amount": number,
}
```
