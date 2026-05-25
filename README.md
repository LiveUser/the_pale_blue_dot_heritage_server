# the_pale_blue_dot_heritage_server

Free Open Source, Open Access, Archaeology Platform. Hecho con orgullo en Puerto Rico por Radamés Jomuel Valentín Reyes.

## Official Instance
The official/original instance of this app can be accessed by visiting [https://the-pale-blue-dot-heritage-project.pages.dev/](https://the-pale-blue-dot-heritage-project.pages.dev/) or by downloading the official android app at [The Google Play Store](https://play.google.com/store/apps/details?id=com.rawware.the_pale_blue_dot_heritage_project&hl=en)

## API
A server created using Google Flutter along with my library [graphene_server](https://pub.dev/packages/graphene_server) and my custom database [objective_db](https://pub.dev/packages/objective_db).

### API Endpoint
Requests should always be of type POST and format the body in BSON format.
~~~
http://localhost:port/graphene
~~~
API POST Body
-----------------------------------------
### Get Objects List
~~~dart
{
  "variables": {
  },
  "query": "get-object-list"
}
~~~
### Login
~~~dart
{
  "variables": {
    "username": "someUsername",
    "password": "somePassword"
  },
  "query": "login"
}
~~~
### Logout
~~~dart
{
  "variables": {
    "username": "someUsername",
    "password": "somePassword"
  },
  "mutation": "logout"
}
~~~
### Create Object
~~~dart
{
  "variables": {
    "accessToken": "tokenFromLoginCall",
    "zenodoDOI": "zenodoDOI",
    "zenodoDownloadLink": "zenodoDownloadLink"
  },
  "mutation": "createObject"
}
~~~
### Modify Object
~~~dart
{
  "variables": {
    "accessToken": "tokenFromLoginCall",
    "zenodoDOI": "zenodoDOI",
    "zenodoDownloadLink": "zenodoDownloadLink",
    "uuid": "uuidOfObjectToModify"
  },
  "mutation": "modifyObject"
}
~~~
### Delete Object
~~~dart
{
  "variables": {
    "accessToken": "tokenFromLoginCall",
    "uuid": "uuidOfObjectToModify"
  },
  "mutation": "delete"
}
~~~
### Sync
~~~dart
{
  "variables": {
    "accessToken": "tokenFromLoginCall",
    "uuid": "uuidOfObjectToModify"
  },
  "mutation": "sync"
}
~~~
### Full Sync
~~~dart
{
  "variables": {
    "accessToken": "tokenFromLoginCall",
  },
  "mutation": "fullSync"
}
~~~