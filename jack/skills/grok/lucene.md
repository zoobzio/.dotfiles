# Lucene

Deep understanding of `github.com/zoobzio/lucene` — type-safe search query builder for Elasticsearch and OpenSearch with schema validation.

## Core Concepts

Lucene builds Elasticsearch/OpenSearch Query DSL as type-safe Go with schema validation. A generic `Builder[T]` extracts field metadata from structs via sentinel, validates field references at query creation time, and renders to engine-specific JSON via pluggable renderers. Errors are deferred — attached to query/aggregation objects for checking at the end.

- **Builder[T]** is the schema-validated query/aggregation factory
- **Query** is a sealed interface — all query types (25+) implement it
- **Aggregation** is a sealed interface — all aggregation types (24+) implement it
- **Search** composes queries, aggregations, sorting, highlighting into a complete request
- **Renderer** converts Search to engine-specific JSON (Elasticsearch V7/V8, OpenSearch V1/V2)

**Dependencies:** `sentinel` (struct metadata extraction)

## Public API

### Builder[T]

```go
func New[T any]() (*Builder[T], error)
```

Returns `ErrUnknownField` sentinel error for invalid field references. Field names resolved from `json` tags.

`Builder[T].Spec() *Spec` — returns extracted schema.

### Query Builders (all methods on Builder[T])

#### Full-Text

| Method | Returns | Purpose |
|--------|---------|---------|
| `Match(field, text)` | `*MatchQuery` | Analyzed text search |
| `MatchPhrase(field, phrase)` | `*MatchPhraseQuery` | Exact phrase |
| `MatchPhrasePrefix(field, phrase)` | `*MatchPhrasePrefixQuery` | Autocomplete prefix |
| `MultiMatch(text, fields...)` | `*MultiMatchQuery` | Multi-field search |
| `QueryString(queryStr)` | `*QueryStringQuery` | Lucene syntax |
| `SimpleQueryString(queryStr)` | `*SimpleQueryStringQuery` | User-friendly syntax |

#### Term-Level

| Method | Returns | Purpose |
|--------|---------|---------|
| `Term(field, value)` | `*TermQuery` | Exact value |
| `Terms(field, values...)` | `*TermsQuery` | Multiple exact values |
| `Range(field)` | `*RangeQuery` | Numeric/date ranges (.Gt/.Gte/.Lt/.Lte) |
| `Exists(field)` | `*ExistsQuery` | Field existence |
| `IDs(ids...)` | `*IDsQuery` | Document ID matching |
| `Prefix(field, prefix)` | `*PrefixQuery` | Prefix matching |
| `Wildcard(field, pattern)` | `*WildcardQuery` | Wildcard patterns |
| `Regexp(field, pattern)` | `*RegexpQuery` | Regex matching |
| `Fuzzy(field, value)` | `*FuzzyQuery` | Edit distance matching |

#### Compound

| Method | Returns | Purpose |
|--------|---------|---------|
| `Bool()` | `*BoolQuery` | Must/Should/MustNot/Filter clauses |
| `And(queries...)` | `*BoolQuery` | Shorthand for Bool().Must() |
| `Or(queries...)` | `*BoolQuery` | Shorthand for Bool().Should() |
| `Not(query)` | `*BoolQuery` | Shorthand for Bool().MustNot() |
| `MatchAll()` | `*MatchAllQuery` | Match all documents |
| `MatchNone()` | `*MatchNoneQuery` | Match no documents |
| `Boosting()` | `*BoostingQuery` | Positive/negative with negative_boost |
| `DisMax(queries...)` | `*DisMaxQuery` | Best match from multiple |
| `ConstantScore(filter)` | `*ConstantScoreQuery` | Constant score wrapper |

#### Nested/Join

| Method | Returns | Purpose |
|--------|---------|---------|
| `Nested(path, inner)` | `*NestedQuery` | Nested object queries |
| `HasChild(childType, inner)` | `*HasChildQuery` | Parent by child |
| `HasParent(parentType, inner)` | `*HasParentQuery` | Child by parent |

#### Vector & Geo

| Method | Returns | Purpose |
|--------|---------|---------|
| `Knn(field, vector)` | `*KnnQuery` | k-NN search ([]float32) |
| `GeoDistance(field, lat, lon)` | `*GeoDistanceQuery` | Radius search |
| `GeoBoundingBox(field)` | `*GeoBoundingBoxQuery` | Bounding box search |

All query types support `.Boost(float64)` and have `.Err() error` for deferred validation. Error propagation: compound queries check all children.

### Aggregation Builders (all methods on Builder[T])

#### Bucket

| Method | Purpose |
|--------|---------|
| `TermsAgg(name, field)` | Group by value (.Size, .MinDocCount, .Order) |
| `Histogram(name, field)` | Numeric buckets (.Interval, .Offset) |
| `DateHistogram(name, field)` | Time-based buckets (.CalendarInterval/.FixedInterval, .Format, .TimeZone) |
| `RangeAgg(name, field)` | Custom ranges (.AddRange) |
| `DateRangeAgg(name, field)` | Date ranges (.AddRange, .Format) |
| `FilterAgg(name, filter)` | Single filter |
| `FiltersAgg(name)` | Named filters (.AddFilter) |
| `NestedAgg(name, path)` | Nested documents |
| `MissingAgg(name, field)` | Missing field count |

#### Metric

| Method | Purpose |
|--------|---------|
| `Avg`, `Sum`, `Min`, `Max` | Basic metrics (.Missing) |
| `Count(name, field)` | Value count |
| `Cardinality(name, field)` | Distinct count (.PrecisionThreshold) |
| `Stats`, `ExtendedStats` | Statistics (.Missing, .Sigma) |
| `Percentiles(name, field)` | Percentile values (.Percents) |
| `TopHits(name)` | Top documents (.Size, .From, .Sort, .Source) |

#### Pipeline

| Method | Purpose |
|--------|---------|
| `AvgBucket`, `SumBucket`, `MaxBucket`, `MinBucket` | Basic pipeline aggs |
| `Derivative(name, path)` | Derivative (.Unit) |
| `CumulativeSum(name, path)` | Cumulative sum |
| `MovingAvg(name, path)` | Moving average (.Window, .Model, .Predict) |

All aggregations support `.SubAggs(aggs...)` for nesting and `.Err() error`.

### Search

```go
lucene.NewSearch().
    Query(query).
    Aggs(aggs...).
    Size(n).From(n).
    Sort(SortField{Field, Order}).
    Source(fields...) / SourceIncludes(fields...) / SourceExcludes(fields...).
    Highlight(highlight).
    TrackTotalHits(bool).
    MinScore(float64).
    Timeout(string)
```

`Search.Err()` checks query, aggregations, and highlight for errors.

### Highlight

```go
type Highlight struct { /* pre_tags, post_tags, encoder, fragment_size, num_fragments, order, type */ }
```

`HighlightFieldBuilder` — fluent per-field configuration with `.FragmentSize`, `.NumFragments`, `.PreTags`, `.PostTags`, `.HighlightQuery`, `.MatchedFields`.

### Renderer Interface

```go
type Renderer interface {
    Render(search *Search) ([]byte, error)
    RenderQuery(query Query) ([]byte, error)
    RenderAggs(aggs []Aggregation) ([]byte, error)
}
```

### Dialect Implementations

| Dialect | Package | Versions | Key Differences |
|---------|---------|----------|-----------------|
| Elasticsearch | `elasticsearch/` | V7, V8 | Standard kNN format |
| OpenSearch | `opensearch/` | V1, V2 | Field-nested kNN format |

Both validate `Search.Err()` before rendering.

## Schema Types

```go
type FieldKind uint8
const (KindString, KindInt, KindFloat, KindBool, KindTime, KindSlice, KindVector, KindUnknown)

type FieldSpec struct { Name, Type string; Kind FieldKind }
type Spec struct { TypeName string; Fields []FieldSpec }
```

Vector types (`[]float32`, `[]float64`) distinguished from generic slices.

## Sentinel Errors

| Error | Purpose |
|-------|---------|
| `ErrUnknownField` | Field name not found in schema |

## Thread Safety

`Builder[T]` is read-only after creation — safe to share. Returned query/aggregation builders are mutable and should not be shared across goroutines.

## File Layout

```
lucene/
├── api.go              # Query interface, Op enum, base types
├── builder.go          # Builder[T] creation
├── spec.go             # FieldKind, FieldSpec, Spec, schema
├── fulltext.go         # Match, MatchPhrase, MultiMatch, QueryString
├── term.go             # Term, Terms, Range, Exists, Prefix, Wildcard, Regexp, Fuzzy
├── compound.go         # Bool, MatchAll, MatchNone, Boosting, DisMax, ConstantScore
├── nested.go           # Nested, HasChild, HasParent
├── vector.go           # Knn
├── geo.go              # GeoDistance, GeoBoundingBox
├── highlight.go        # Highlight, HighlightField builder
├── render.go           # Search, Renderer interface, SortField
├── aggregation.go      # Bucket aggregations
├── metric.go           # Metric aggregations
├── pipeline.go         # Pipeline aggregations
├── elasticsearch/      # Elasticsearch renderer (V7, V8)
├── opensearch/         # OpenSearch renderer (V1, V2)
├── internal/marshal/   # JSON marshaling types
└── testing/
    └── helpers.go      # AssertQueryString, AssertNoError, AssertError
```

## Common Patterns

**Schema-validated query:**

```go
b, _ := lucene.New[Product]()
query := b.Bool().
    Must(b.Match("title", "wireless headphones")).
    Filter(b.Range("price").Gte(50).Lte(200))

search := lucene.NewSearch().
    Query(query).
    Aggs(b.TermsAgg("brands", "brand").Size(10)).
    Size(20).
    Sort(lucene.SortField{Field: "price", Order: "asc"})

renderer := elasticsearch.NewRenderer(elasticsearch.V8)
json, _ := renderer.Render(search)
```

**k-NN vector search:**

```go
query := b.Knn("embedding", queryVector).K(10).NumCandidates(100)
```

## Ecosystem

Lucene depends on:
- **sentinel** — struct metadata extraction for field validation

Lucene is consumed by:
- Applications for Elasticsearch/OpenSearch queries
