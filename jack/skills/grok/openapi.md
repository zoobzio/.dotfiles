# OpenAPI

Deep understanding of `github.com/zoobzio/openapi` — OpenAPI 3.1 specification as native Go types.

## Core Concepts

A comprehensive Go implementation of the OpenAPI 3.1 specification as type definitions. Build, read, and write specs with full type safety. No code generation — just Go structs with JSON/YAML serialisation.

- **OpenAPI** is the root document type
- All spec objects are Go structs with `json:` and `yaml:` tags
- **SchemaType** handles the 3.1 feature where `type` can be a string or array
- Dual serialisation: JSON and YAML with lossless roundtripping

**Dependencies:** `yaml.v3`

## Public API

### Root Type

```go
type OpenAPI struct {
    OpenAPI      string                    // Required: "3.1.0"
    Info         Info                      // Required
    Paths        map[string]PathItem       // Required
    Webhooks     map[string]*PathItem
    Components   *Components
    Servers      []Server
    Security     []SecurityRequirement
    Tags         []Tag
    TagGroups    []TagGroup                // Redoc extension
    ExternalDocs *ExternalDocumentation
}
```

### Serialisation

| Function/Method | Signature | Behaviour |
|-----------------|-----------|-----------|
| `(*OpenAPI) ToJSON` | `ToJSON() ([]byte, error)` | Marshal to JSON |
| `FromJSON` | `FromJSON(data []byte) (*OpenAPI, error)` | Unmarshal from JSON |
| `(*OpenAPI) ToYAML` | `ToYAML() ([]byte, error)` | Marshal to YAML |
| `FromYAML` | `FromYAML(data []byte) (*OpenAPI, error)` | Unmarshal from YAML |

### SchemaType

Handles OpenAPI 3.1's flexible `type` field (single string or array of strings).

| Constructor | Signature |
|-------------|-----------|
| `NewSchemaType` | `NewSchemaType(s string) *SchemaType` |
| `NewSchemaTypes` | `NewSchemaTypes(s []string) *SchemaType` |

| Method | Behaviour |
|--------|-----------|
| `IsEmpty()` | No type set |
| `IsArray()` | Multiple types |
| `String()` | Single string (first element for arrays) |
| `Strings()` | Slice of types |
| `Contains(s)` | Type present |
| `IsNullable()` | Contains "null" |

Custom JSON/YAML marshalling: single-element arrays normalise to strings.

### All Modelled Types

| Category | Types |
|----------|-------|
| Document | `OpenAPI`, `Info`, `Contact`, `License` |
| Server | `Server`, `ServerVariable` |
| Paths | `PathItem`, `Operation` |
| Parameters | `Parameter`, `Header` |
| Request/Response | `RequestBody`, `Response`, `MediaType`, `Encoding` |
| Schema | `Schema` (full JSON Schema with AllOf/OneOf/AnyOf/Not, validation constraints, discriminator) |
| Examples | `Example` |
| Components | `Components` (schemas, responses, parameters, examples, request bodies, headers, security schemes, links, callbacks, path items) |
| Security | `SecurityScheme`, `OAuthFlows`, `OAuthFlow`, `SecurityRequirement` |
| Documentation | `Tag`, `TagGroup`, `ExternalDocumentation` |
| Advanced | `Link`, `Callback`, `Discriminator`, `XML` |

## File Layout

```
openapi/
├── openapi.go      # All type definitions (~47 exported types)
├── schema_type.go  # SchemaType with custom marshalling
├── json.go         # JSON serialisation
└── yaml.go         # YAML serialisation
```

## Common Patterns

**Building a Spec:**

```go
spec := &openapi.OpenAPI{
    OpenAPI: "3.1.0",
    Info:    openapi.Info{Title: "My API", Version: "1.0.0"},
    Paths: map[string]openapi.PathItem{
        "/users": {
            Get: &openapi.Operation{
                Summary:   "List users",
                Responses: map[string]openapi.Response{"200": {Description: "Success"}},
            },
        },
    },
    Components: &openapi.Components{
        Schemas: map[string]*openapi.Schema{
            "User": {
                Type:       openapi.NewSchemaType("object"),
                Properties: map[string]*openapi.Schema{"id": {Type: openapi.NewSchemaType("string")}},
            },
        },
    },
}
jsonBytes, _ := spec.ToJSON()
```

## Ecosystem

OpenAPI is consumed by:
- **rocco** — generates OpenAPI specs from handler type metadata
