#### These are the current config options for the official BeeStation server. If you plan to host your own fork of our code you are heavily encouraged to review and update these files for your needs.

## Topics Documentation
Beestation uses a heavily modified topic system originally from Aurorastation, which uses JSON objects for requests to and responses from the server.

### Configuration
Topic config is managed by the **comms.txt** config file. Topic configuration consists of four types of config entry.
* `CROSS_COMMS_NAME` Name the server calls itself in outgoing topics.
* `COMMS_KEY` Multiple of these entries are supported. Consists of a key-value pair of a token (should be randomly generated for security) and the authorized scopes of that token. A list of scopes can be found in the comms.txt file.
* `CROSS_SERVER` Multiple of these entries are supported. This entry is a key-value pair of a server's BYOND address and the token that has access to the remote server. For more information, see [Handshake](#handshake)
* `SERVER_HOP` Multiple of these entries are supported. Each entry is a key-value pair of a server name and a byond address. These servers are not authenticated in any way, and are a list of servers that can be quickly switched to by players using the **Server Hop** verb.

### Requests
Topic requests consist of a JSON object with three mandatory keys: `auth`, `query` and `source`, as well as optional request-specific keys.

* `auth` is the token used to access features on the target server. Can either be configured for use by the server operator, or be the `anonymous` token. The `anonymous` token is a public-access token that allows requests to collect data about player counts, round status etc. For more sensitive information, or to interact with the server itself, a specific auth token will be needed.
* `query` is the name of the topic function being performed. Examples include `status` and `playerlist`. The query used determines which optional keys must be provided (if any). For a full list of topic functions available, and for additional required keys, see **code/datums/world_topic.dm**
* `source` this is an identifier for the server sending the request, for logging and administrative purposes.

Example Request:
```json
{
	"auth": "8w7y487238q8x7nqw8dhwe8fq34r89gewri",
	"query": "ahelp",
	"source": "BeeStation Sage",
	"message_sender": "a_player",
	"message": "I don't see any admins online, can someone help? CE just killed me in maint 4noraisin"
}
```

### Response
Topic responses are very simple, and consist of three keys: `statuscode`, `response` and `data`

* `statuscode` is a number that represents what the outcome of a request was. For example; a response with a status code of `200` means the request succeeded, and a response with a status code of `401` means that the request was lacking or had invalid authorization.
* `response` is a simple text response detailing the outcome of the request. This key will provide error details for non-`200` status codes, and a short description of actions performed if the request was successful.
* `data` is a misc key which can contain response data specific to the request. The format of this variable depends on the topic used. For information on what data specific topics return, see **code/datums/world_topic.dm**

Example Response:
```json
{
	"statuscode": 200,
	"response": "Player count retrieved",
	"data": 57
}
```

### Handshake
Before being able to send *outgoing* topic calls, a server must handshake with the target server to check what methods it has access to, and to verify that the other server is authorized to receive sensitive information.

#### Initiating Server
The first step of the process is when the server initiating the handshake first starts up. The initiating server will make a call to the target server's `api_do_handshake` method with the token for that server as specified in the config.
The target server will then either respond that the token is unauthorized, or with a list of query methods that the connecting server is allowed to use, along with a token it has stored for the initiating server.

The initiating server will then compare the list of functions received from the remote server with the list of functions sent by the remote server with the list of functions the initiating server has for the token the remote server sent back. Functions present in *both lists* will then be stored in a global list under the the server address of the remote server.

This list is then used to decide what servers to forward sensitive information to, such as ahelps, by only allowing data to be sent out after both servers verify authorization at both ends.

#### Remote Server
When a server receives a request to the `api_do_handshake` method, it will lookup the list of functions authorized for the provided token, as well as look for a configured token for the connecting server based on its IP address. If neither of these things are found, the server will respond with a 401 unauthorized response.

If both prerequisites are found, the server will respond with the token it has stored for the server, as well as the list of authorized functions it found. In addition, if the server does not have the requesting server's functions stored too, it will make its own handshake request to the requesting server to collect the neccessary information.
