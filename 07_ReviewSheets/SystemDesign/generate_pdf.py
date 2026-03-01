#!/usr/bin/env python3
"""Generate a QuickStudy-style PDF cheat sheet for System Design interviews."""

from fpdf import FPDF
import os

# ── Colors ────────────────────────────────────────────────
HEADER_BG   = (30, 60, 110)    # dark blue
SECTION_BG  = (55, 90, 145)    # medium blue
SUBSECT_BG  = (200, 215, 235)  # light blue
CODE_BG     = (245, 245, 245)  # light gray
WHITE       = (255, 255, 255)
BLACK       = (30, 30, 30)
DARK_GRAY   = (60, 60, 60)

class CheatSheet(FPDF):
    def __init__(self):
        super().__init__(orientation="L", unit="mm", format="letter")
        self.set_auto_page_break(auto=False)
        self.col_count = 3
        self.margin = 6
        self.col_gap = 4
        self.usable_w = self.w - 2 * self.margin
        self.col_w = (self.usable_w - (self.col_count - 1) * self.col_gap) / self.col_count
        self.col_idx = 0
        self.col_x = self.margin
        self.col_top = 18  # below page header
        self.col_y = self.col_top
        self.current_page_title = ""
        self._pending_subsect = None
        self.alias_nb_pages()

    def page_header(self, title):
        self.current_page_title = title
        self.set_fill_color(*HEADER_BG)
        self.set_text_color(*WHITE)
        self.set_font("Helvetica", "B", 14)
        self.rect(0, 0, self.w, 14, "F")
        self.set_xy(self.margin, 2)
        self.cell(self.usable_w, 10, title, align="C")
        self.col_y = self.col_top

    def footer(self):
        self.set_y(self.h - self.margin + 1)
        self.set_font("Helvetica", "", 5)
        self.set_text_color(150, 150, 150)
        self.cell(0, 3, f"Page {self.page_no()}/{{nb}}", align="C")

    def _col_left(self):
        return self.margin + self.col_idx * (self.col_w + self.col_gap)

    def _check_space(self, needed):
        if self.col_y + needed > self.h - self.margin:
            self.col_idx += 1
            self.col_y = self.col_top
            if self.col_idx >= self.col_count:
                self.add_page()
                base = self.current_page_title.replace(" (cont.)", "")
                self.page_header(base + " (cont.)")
                self.col_idx = 0
                self.col_y = self.col_top

    def _flush_pending_subsect(self):
        if self._pending_subsect is not None:
            title = self._pending_subsect
            self._pending_subsect = None
            x = self._col_left()
            self.set_fill_color(*SUBSECT_BG)
            self.set_text_color(*BLACK)
            self.set_font("Helvetica", "B", 6.5)
            self.set_xy(x, self.col_y)
            self.cell(self.col_w, 4.5, f"  {title}", fill=True)
            self.col_y += 5.5

    def new_page(self, title):
        self._pending_subsect = None
        self.add_page()
        self.page_header(title)
        self.col_idx = 0
        self.col_y = self.col_top

    def section(self, title):
        self._pending_subsect = None
        self._check_space(7)
        x = self._col_left()
        self.set_fill_color(*SECTION_BG)
        self.set_text_color(*WHITE)
        self.set_font("Helvetica", "B", 8)
        self.set_xy(x, self.col_y)
        self.cell(self.col_w, 5.5, f"  {title}", fill=True)
        self.col_y += 6.5

    def subsection(self, title):
        self._pending_subsect = title

    def code_block(self, text):
        lines = text.strip().split("\n")
        needed = len(lines) * 3.4 + 2
        if self._pending_subsect is not None:
            self._check_space(5.5 + needed)
            self._flush_pending_subsect()
        else:
            self._check_space(needed)
        self.set_font("Courier", "", 5.5)
        self.set_text_color(*DARK_GRAY)
        available_w = self.col_w - 2
        max_chars = int(available_w / self.get_string_width("M"))
        x = self._col_left()
        y_start = self.col_y
        self.set_fill_color(*CODE_BG)
        self.rect(x, y_start, self.col_w, needed, "F")
        cy = y_start + 1
        for line in lines:
            self.set_xy(x + 1, cy)
            self.cell(available_w, 3.2, line[:max_chars])
            cy += 3.4
        self.col_y = y_start + needed + 0.5

    def body_text(self, text):
        lines = text.strip().split("\n")
        needed = len(lines) * 3.2 + 1
        if self._pending_subsect is not None:
            self._check_space(5.5 + needed)
            self._flush_pending_subsect()
        else:
            self._check_space(needed)
        self.set_font("Helvetica", "", 6)
        self.set_text_color(*DARK_GRAY)
        x = self._col_left()
        available_w = self.col_w - 3
        for line in lines:
            self.set_xy(x + 1.5, self.col_y)
            truncated = line
            while len(truncated) > 0 and self.get_string_width(truncated) > available_w:
                truncated = truncated[:-1]
            self.cell(available_w, 3, truncated)
            self.col_y += 3.2
        self.col_y += 1

    def compact_list(self, label, items):
        x = self._col_left()
        self.set_font("Helvetica", "B", 6)
        self.set_text_color(*BLACK)
        label_w = self.get_string_width(label + " ") + 1

        self.set_font("Helvetica", "", 5.8)
        self.set_text_color(*DARK_GRAY)
        item_str = ", ".join(items)
        full = label + " " + item_str

        available_w = self.col_w - 3
        est_lines = max(1, int(self.get_string_width(full) / available_w) + 1)
        needed = est_lines * 3.2 + 1
        self._check_space(needed)
        x = self._col_left()

        self.set_xy(x + 1.5, self.col_y)
        self.set_font("Helvetica", "B", 6)
        self.set_text_color(*BLACK)
        self.cell(label_w, 3, label + " ")

        self.set_font("Courier", "", 5.5)
        self.set_text_color(*DARK_GRAY)
        self.set_xy(x + 1.5 + label_w, self.col_y)
        self.multi_cell(available_w - label_w, 3.2, item_str)
        self.col_y = self.get_y() + 0.8

    def spacer(self, h=2):
        self.col_y += h


def build():
    pdf = CheatSheet()

    # ══════════════════════════════════════════════════════════
    #  PAGE 1 -- Request Flow & Edge Layer
    # ══════════════════════════════════════════════════════════
    pdf.add_page()
    pdf.page_header("Request Flow & Edge Layer")

    # ── FULL REQUEST PATH ──
    pdf.section("Device to Backend: Full Request Path")
    pdf.code_block(
        'Mobile/Browser\n'
        '     |\n'
        '     v\n'
        'DNS Resolution -- returns IP (or CDN edge IP)\n'
        '     |\n'
        '     v\n'
        'CDN (CloudFront, Akamai) -- static assets, cached\n'
        '     |  (cache miss)\n'
        '     v\n'
        'Load Balancer (L4/L7) -- distributes traffic\n'
        '     |\n'
        '     v\n'
        'API Gateway / Edge -- auth, rate-limit, routing\n'
        '     |\n'
        '     v\n'
        'Application Service(s) -- business logic\n'
        '     |\n'
        '     +-> Cache (Redis)        +-> SQL DB (Postgres)\n'
        '     +-> NoSQL (Cassandra)    +-> Queue (Kafka)\n'
        '     +-> Object Store (S3)    +-> Search (Elastic)'
    )

    # ── DNS ──
    pdf.section("DNS")
    pdf.body_text(
        'Translates domain name to IP address.\n'
        'TTL controls how long clients cache the answer.'
    )
    pdf.compact_list("Records:", ["A (IPv4)", "AAAA (IPv6)", "CNAME (alias)", "MX (mail)"])
    pdf.compact_list("Routing:", ["round-robin", "latency-based", "geo-based", "weighted", "failover"])

    # ── CDN ──
    pdf.section("CDN (Content Delivery Network)")
    pdf.body_text(
        'Edge servers geographically close to users.\n'
        'Caches static assets: images, JS, CSS, videos, fonts.\n'
        'Can also cache API responses (Cache-Control headers).'
    )
    pdf.compact_list("Push:", ["origin uploads proactively (large/static files)"])
    pdf.compact_list("Pull:", ["CDN fetches on first request, then caches (simpler)"])
    pdf.compact_list("Invalidation:", ["TTL expiry", "versioned URLs", "purge API"])
    pdf.compact_list("Examples:", ["CloudFront", "Akamai", "Cloudflare", "Fastly"])

    # ── LOAD BALANCER ──
    pdf.section("Load Balancer")
    pdf.body_text(
        'Distributes incoming traffic across server instances.\n'
        'L4 (Transport): routes by IP/port, fast, no payload inspection.\n'
        'L7 (Application): routes by URL, headers, cookies -- smarter.'
    )
    pdf.compact_list("Algorithms:", [
        "round-robin", "weighted round-robin", "least connections",
        "IP hash", "consistent hashing"
    ])
    pdf.body_text(
        'Health checks: periodic pings, removes unhealthy instances.\n'
        'SSL termination: decrypt HTTPS at LB, forward HTTP internally.'
    )
    pdf.compact_list("Examples:", ["AWS ALB/NLB", "Nginx", "HAProxy", "Envoy"])

    # ── API GATEWAY ──
    pdf.section("API Gateway / Edge Layer")
    pdf.body_text(
        'Single entry point for all client requests.\n'
        'Responsibilities:'
    )
    pdf.code_block(
        'Authentication & Authorization -- validate JWT/OAuth\n'
        'Rate Limiting -- protect backends from overload\n'
        'Request Routing -- fan out to correct microservice\n'
        'Protocol Translation -- REST <-> gRPC, HTTP <-> WS\n'
        'Request/Response Transform -- headers, reshape\n'
        'API Versioning -- route /v1/ vs /v2/\n'
        'Request Validation -- schema checks\n'
        'Circuit Breaking -- stop traffic to failing svcs\n'
        'Logging & Metrics -- centralized observability\n'
        'CORS handling -- cross-origin policies'
    )
    pdf.compact_list("Examples:", ["Kong", "AWS API Gateway", "Apigee", "Envoy"])

    # ── RATE LIMITING ──
    pdf.section("Rate Limiting Algorithms")
    pdf.subsection("Token Bucket")
    pdf.body_text(
        'Tokens added at fixed rate, request costs 1 token.\n'
        'Allows bursts (up to bucket capacity), smooth long-term rate.'
    )
    pdf.subsection("Sliding Window Log")
    pdf.body_text(
        'Track timestamp of each request in a window.\n'
        'Precise, no boundary spikes. Cons: stores all timestamps.'
    )
    pdf.subsection("Sliding Window Counter")
    pdf.body_text(
        'Hybrid: weight current + previous window counts.\n'
        'Memory-efficient, smooths boundary edges.'
    )
    pdf.subsection("Fixed Window Counter")
    pdf.body_text(
        'Count requests per time window.\n'
        'Simple. Cons: boundary spike (2x rate at window edges).'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 2 -- API Design
    # ══════════════════════════════════════════════════════════
    pdf.new_page("API Design")

    # ── REST ──
    pdf.section("REST API Best Practices")
    pdf.subsection("Naming")
    pdf.body_text(
        'Use nouns, not verbs: /users, /orders (not /getUsers).\n'
        'Plural resource names: /users/{id}/orders.\n'
        'Nested for relationships (max 2 levels deep).\n'
        'Query params for filtering: ?status=active&sort=name.\n'
        'Use kebab-case for multi-word: /order-items.'
    )
    pdf.subsection("HTTP Methods")
    pdf.code_block(
        'GET    /users       -- list (idempotent, cacheable)\n'
        'GET    /users/{id}  -- get single\n'
        'POST   /users       -- create (not idempotent)\n'
        'PUT    /users/{id}  -- full replace (idempotent)\n'
        'PATCH  /users/{id}  -- partial update (idempotent)\n'
        'DELETE /users/{id}  -- delete (idempotent)'
    )
    pdf.subsection("Status Codes")
    pdf.code_block(
        '200 OK             201 Created        204 No Content\n'
        '400 Bad Request    401 Unauthorized   403 Forbidden\n'
        '404 Not Found      409 Conflict       429 Too Many Reqs\n'
        '500 Internal Error 502 Bad Gateway    503 Service Unavail'
    )
    pdf.subsection("Pagination")
    pdf.body_text(
        'Offset-based: ?offset=20&limit=10 (simple, skip is O(n)).\n'
        'Cursor-based: ?cursor=abc&limit=10 (stable, efficient).\n'
        'Response: { data: [...], next_cursor: "x", has_more: true }'
    )
    pdf.subsection("Versioning")
    pdf.compact_list("Approaches:", [
        "URL path: /api/v1/ (most common)",
        "Header: Accept: vnd.api.v2+json",
        "Query: ?version=2"
    ])
    pdf.subsection("Idempotency")
    pdf.body_text(
        'GET, PUT, DELETE are naturally idempotent.\n'
        'POST: use Idempotency-Key header (client sends UUID).\n'
        'Server stores result by key, returns same on retry.'
    )

    # ── GRAPHQL ──
    pdf.section("GraphQL")
    pdf.body_text(
        'Client specifies exactly what data it needs in one request.\n'
        'Single endpoint: POST /graphql.'
    )
    pdf.subsection("Query (read)")
    pdf.code_block(
        'query {\n'
        '  user(id: "1") {\n'
        '    name\n'
        '    email\n'
        '    posts(limit: 5) { title, createdAt }\n'
        '  }\n'
        '}'
    )
    pdf.subsection("Mutation (write)")
    pdf.code_block(
        'mutation {\n'
        '  createUser(input: { name: "Alice" }) {\n'
        '    id\n'
        '    name\n'
        '  }\n'
        '}'
    )
    pdf.subsection("Subscription (real-time, WebSocket)")
    pdf.code_block(
        'subscription {\n'
        '  messageAdded(chatId: "123") {\n'
        '    id, text, sender { name }\n'
        '  }\n'
        '}'
    )
    pdf.body_text(
        'Schema: strongly typed, defines types/queries/mutations.\n'
        'Resolvers: functions that fetch data for each field.\n'
        'N+1 problem: use DataLoader (batches + caches per request).'
    )
    pdf.subsection("GraphQL vs REST")
    pdf.code_block(
        'GraphQL                     REST\n'
        'Flexible queries            Fixed endpoints\n'
        'Single round-trip           May need multiple calls\n'
        'Harder to cache (POST)      HTTP caching native\n'
        'Complex server              Simpler server\n'
        'Schema = documentation      Needs OpenAPI/Swagger\n'
        'Better for mobile           Better for simple CRUD'
    )

    # ── GRPC ──
    pdf.section("gRPC")
    pdf.body_text(
        'Binary protocol over HTTP/2 (faster than JSON/HTTP1.1).\n'
        'Protocol Buffers (protobuf) for serialization.\n'
        'Streaming: unary, server, client, bidirectional.\n'
        'Code gen: .proto file -> stubs in any language.\n'
        'Best for: service-to-service, low-latency, high-throughput.\n'
        'Not great for: browser clients (need gRPC-Web proxy).'
    )

    # ── WEBSOCKETS ──
    pdf.section("WebSockets & SSE")
    pdf.body_text(
        'WebSocket: full-duplex, persistent connection.\n'
        'Upgrade from HTTP via Upgrade: websocket header.\n'
        'Use for: chat, live notifications, collab editing.\n'
        'Stateful -- harder to LB (sticky sessions or pub/sub).\n'
        'SSE (Server-Sent Events): server push only, simpler,\n'
        'HTTP-based, auto-reconnect. Good for live feeds.'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 3 -- Databases
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Databases")

    # ── POSTGRES ──
    pdf.section("PostgreSQL (Relational / SQL)")
    pdf.body_text(
        'Structured data with relationships (users, orders).\n'
        'ACID transactions, complex queries, JOINs, aggregations.'
    )
    pdf.subsection("ACID")
    pdf.code_block(
        'Atomicity    -- all or nothing (full commit or rollback)\n'
        'Consistency  -- data always valid per constraints\n'
        'Isolation    -- concurrent txns don\'t interfere\n'
        'Durability   -- committed data survives crashes (WAL)'
    )
    pdf.subsection("Isolation Levels (weakest to strongest)")
    pdf.code_block(
        'Read Uncommitted -- dirty reads possible\n'
        'Read Committed   -- only committed data (PG default)\n'
        'Repeatable Read  -- snapshot at txn start\n'
        'Serializable     -- full isolation, as if sequential'
    )
    pdf.subsection("Indexes")
    pdf.code_block(
        'B-tree (default): equality + range, most common\n'
        'Hash: equality only, rarely used\n'
        'GIN: full-text search, JSONB, arrays\n'
        'GiST: geometric, spatial data\n'
        'Composite: CREATE INDEX idx ON t(a, b)\n'
        '  -- leftmost prefix rule\n'
        'Covering: INCLUDE (col) -- avoids table lookup\n'
        'Partial: WHERE active = true -- smaller, faster'
    )
    pdf.subsection("Connection Pooling")
    pdf.body_text(
        'PG forks a process per connection (expensive).\n'
        'Use PgBouncer: app -> pool (20-50 conns) -> Postgres.'
    )
    pdf.subsection("Replication")
    pdf.body_text(
        'Streaming replication: primary -> replica(s).\n'
        'Read replicas: route reads to replicas, writes to primary.\n'
        'Failover: promote replica on primary failure.'
    )
    pdf.body_text(
        'EXPLAIN ANALYZE SELECT ... -- shows plan + timings.\n'
        'Look for: Seq Scan (bad), Index Scan (good).'
    )

    # ── CASSANDRA ──
    pdf.section("Cassandra (NoSQL - Wide Column)")
    pdf.body_text(
        'Massive write throughput (time-series, logs, IoT).\n'
        'No single point of failure (peer-to-peer, no master).\n'
        'Horizontal scaling to hundreds of nodes.\n'
        'Queries must be known in advance (table per query).'
    )
    pdf.subsection("Data Model")
    pdf.code_block(
        'Keyspace -> Table -> Partition -> Rows\n'
        'Primary key = Partition key + Clustering columns\n'
        '  Partition key: which node stores the data\n'
        '  Clustering cols: sort order within partition\n'
        '\n'
        'CREATE TABLE posts_by_user (\n'
        '    user_id UUID,\n'
        '    created_at TIMESTAMP,\n'
        '    post_id UUID,\n'
        '    content TEXT,\n'
        '    PRIMARY KEY (user_id, created_at)\n'
        ') WITH CLUSTERING ORDER BY (created_at DESC);'
    )
    pdf.subsection("Consistency Levels")
    pdf.code_block(
        'ONE          -- fastest, 1 replica\n'
        'QUORUM       -- majority (N/2 + 1), strong\n'
        'ALL          -- all replicas, slowest\n'
        'LOCAL_QUORUM -- quorum in local DC\n'
        'R + W > N = strong consistency'
    )
    pdf.subsection("Anti-patterns")
    pdf.body_text(
        'No JOINs. No cross-partition aggregations.\n'
        'No secondary indexes on high-cardinality columns.\n'
        'Avoid read-before-write (use LWT sparingly).'
    )
    pdf.subsection("Cassandra vs Postgres")
    pdf.code_block(
        'Cassandra                  Postgres\n'
        'AP (avail + partition)     CP (consistent + partition)\n'
        'No JOINs, limited query    Rich SQL, JOINs, aggs\n'
        'Linear horizontal scale    Vertical + read replicas\n'
        'Eventual consistency       Strong consistency\n'
        'Design table per query     Normalize, query flexibly'
    )

    # ── OTHER NOSQL ──
    pdf.section("Other NoSQL Options")
    pdf.subsection("MongoDB (Document Store)")
    pdf.body_text(
        'JSON-like docs (BSON), flexible schema.\n'
        'Good for: CMS, catalogs, user profiles.\n'
        'Rich queries, secondary indexes, aggregation pipeline.'
    )
    pdf.subsection("DynamoDB (AWS Managed Key-Value)")
    pdf.body_text(
        'Single-digit ms latency at any scale.\n'
        'Partition key + optional sort key.\n'
        'Good for: sessions, carts, leaderboards.\n'
        'DAX for caching, global tables for multi-region.'
    )
    pdf.subsection("Neo4j (Graph DB)")
    pdf.body_text(
        'Nodes + edges with properties, Cypher queries.\n'
        'Good for: social networks, recommendations, fraud.'
    )
    pdf.subsection("Time-Series (InfluxDB, TimescaleDB)")
    pdf.body_text(
        'Optimized for time-stamped data: metrics, IoT.\n'
        'Auto downsampling and retention policies.'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 4 -- Caching, Queues & Streaming
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Caching, Queues & Streaming")

    # ── REDIS ──
    pdf.section("Redis (In-Memory Cache / Data Store)")
    pdf.body_text(
        'In-memory key-value store, sub-millisecond reads.'
    )
    pdf.compact_list("Data types:", [
        "strings", "hashes", "lists", "sets",
        "sorted sets", "streams", "HyperLogLog"
    ])
    pdf.compact_list("Use cases:", [
        "cache", "rate limiting", "leaderboards",
        "pub/sub", "distributed locks", "counters", "queues"
    ])

    pdf.subsection("Cache-Aside (Lazy Loading)")
    pdf.body_text(
        'Read: cache -> miss -> DB -> write cache -> return.\n'
        'Write: write DB -> invalidate cache (delete key).\n'
        'Pros: only caches what is read, cache failure non-fatal.\n'
        'Cons: miss penalty (3 round-trips), stale data possible.'
    )
    pdf.subsection("Write-Through")
    pdf.body_text(
        'Write cache + DB together (synchronous).\n'
        'Pros: cache always consistent. Cons: write latency.'
    )
    pdf.subsection("Write-Behind (Write-Back)")
    pdf.body_text(
        'Write cache -> async flush to DB (batched).\n'
        'Pros: fast writes. Cons: data loss if cache crashes.'
    )
    pdf.subsection("Read-Through")
    pdf.body_text(
        'Cache itself fetches from DB on miss.\n'
        'Similar to cache-aside but cache handles the logic.'
    )
    pdf.subsection("Eviction Policies")
    pdf.compact_list("Policies:", [
        "LRU (Least Recently Used) -- most common",
        "LFU (Least Frequently Used)",
        "TTL (Time To Live)",
        "Random"
    ])
    pdf.subsection("Cache Problems")
    pdf.body_text(
        'Thundering herd: many hit DB on cache expiry.\n'
        '  Fix: lock, stale-while-revalidate, pre-warm.\n'
        'Stale data: cache and DB drift.\n'
        '  Fix: short TTLs, event-driven invalidation.\n'
        'Hot key: single key gets extreme traffic.\n'
        '  Fix: local cache + distributed, key replication.'
    )

    # ── KAFKA ──
    pdf.section("Kafka (Distributed Event Streaming)")
    pdf.body_text(
        'Distributed, append-only commit log.\n'
        'Messages persist (configurable retention).\n'
        'Producers -> Topics -> Partitions -> Consumer Groups.'
    )
    pdf.subsection("Core Concepts")
    pdf.code_block(
        'Topic       -- named feed / category of messages\n'
        'Partition   -- ordered, immutable seq within topic\n'
        'Offset      -- position of msg within partition\n'
        'Producer    -- writes messages to topics\n'
        'Consumer    -- reads messages from topics\n'
        'Consumer Grp -- consumers share partitions\n'
        'Broker      -- single Kafka server node\n'
        'Cluster     -- group of brokers'
    )
    pdf.subsection("Key Properties")
    pdf.body_text(
        'Ordering guaranteed within a partition (not across).\n'
        'Same key -> same partition (ordering per entity).\n'
        'Consumer group: each partition -> 1 consumer.\n'
        '  Max parallelism = number of partitions.\n'
        'Messages NOT deleted after consumption (retained).\n'
        'Replay: seek to earlier offset to re-read.'
    )
    pdf.subsection("When to Use")
    pdf.body_text(
        'Event-driven arch (order -> inventory, email, analytics).\n'
        'Log aggregation, stream processing, CDC propagation.\n'
        'Decoupling producers from consumers.\n'
        'High throughput (millions of msgs/sec).'
    )
    pdf.subsection("Kafka vs Traditional Queue (RabbitMQ/SQS)")
    pdf.code_block(
        'Kafka                    RabbitMQ / SQS\n'
        'Log-based, persistent    Queue, msg deleted on ACK\n'
        'Replay possible          No replay\n'
        'Consumer groups          Competing consumers\n'
        'High throughput          Lower latency per msg\n'
        'Order per partition      Order per queue (FIFO)'
    )

    # ── MESSAGE PATTERNS ──
    pdf.section("Message Queue Patterns")
    pdf.subsection("Point-to-Point")
    pdf.body_text(
        'One producer -> queue -> one consumer per message.\n'
        'Use: task queues, background work (emails, images).'
    )
    pdf.subsection("Pub/Sub")
    pdf.body_text(
        'Producer publishes to topic, all subscribers get a copy.\n'
        'Use: event fan-out (order -> email + inventory + analytics).'
    )
    pdf.subsection("Dead Letter Queue (DLQ)")
    pdf.body_text(
        'Messages failing N times -> moved to DLQ.\n'
        'Allows inspection, debugging, manual replay.\n'
        'Always configure DLQ for production queues.'
    )
    pdf.subsection("Delivery Guarantees")
    pdf.body_text(
        'At-most-once: fire and forget (may lose msgs).\n'
        'At-least-once: retry until ACK (may duplicate).\n'
        'Exactly-once: at-least-once + idempotent consumer.\n'
        '  Pattern: dedup by message ID.'
    )
    pdf.subsection("Backpressure")
    pdf.body_text(
        'Consumer can\'t keep up with producer.\n'
        'Fix: buffer (queue depth), rate-limit producer,\n'
        'scale consumers, drop/sample.'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 5 -- CDC, Sharding & Data Patterns
    # ══════════════════════════════════════════════════════════
    pdf.new_page("CDC, Sharding & Data Patterns")

    # ── CDC ──
    pdf.section("CDC (Change Data Capture)")
    pdf.body_text(
        'Captures row-level changes (INSERT/UPDATE/DELETE)\n'
        'from a database and streams them as events.'
    )
    pdf.subsection("How It Works")
    pdf.code_block(
        'Log-based (preferred):\n'
        '  Reads DB write-ahead log (WAL/binlog)\n'
        '  Postgres -> logical replication slots\n'
        '  MySQL -> binlog\n'
        '  Tool: Debezium (open source) -> Kafka Connect\n'
        '\n'
        'Trigger-based: DB triggers write to changelog\n'
        'Polling: periodically query for changed rows'
    )
    pdf.subsection("Architecture")
    pdf.code_block(
        'Postgres (WAL) -> Debezium -> Kafka -> consumers\n'
        '                                 +-> Elasticsearch\n'
        '                                 +-> Redis (cache)\n'
        '                                 +-> Data Warehouse\n'
        '                                 +-> Microservice'
    )
    pdf.subsection("Rules & Best Practices")
    pdf.body_text(
        'Every table needs a primary key (CDC needs it).\n'
        'Include updated_at timestamp for ordering/debug.\n'
        'Schema changes need careful handling (schema registry).\n'
        'Consumers MUST be idempotent (duplicates on restart).\n'
        'Tombstone: DELETE emits key + null (signal to delete).\n'
        'Ordering: guaranteed per PK within a partition.\n'
        'Snapshot: full-table on first start, then incremental.'
    )
    pdf.subsection("When to Use")
    pdf.body_text(
        'Keep caches in sync without app-level invalidation.\n'
        'Populate search indexes from source-of-truth DB.\n'
        'Replicate data across microservices (loose coupling).\n'
        'Feed data warehouse / data lake for analytics.'
    )

    # ── SHARDING ──
    pdf.section("Sharding (Horizontal Partitioning)")
    pdf.body_text(
        'Split data across multiple DB instances (shards).\n'
        'Each shard holds a subset of data.\n'
        'Enables horizontal scaling beyond single-node limits.'
    )
    pdf.subsection("Key/Hash-Based")
    pdf.body_text(
        'shard = hash(key) % num_shards.\n'
        'Pros: even distribution.\n'
        'Cons: resharding painful (all data moves).\n'
        'Better: consistent hashing (only K/N data moves).'
    )
    pdf.subsection("Range-Based")
    pdf.body_text(
        'Users A-M -> shard 1, N-Z -> shard 2.\n'
        'Pros: range queries on one shard.\n'
        'Cons: hot spots (some ranges busier).'
    )
    pdf.subsection("Directory/Lookup")
    pdf.body_text(
        'Lookup service maps key -> shard.\n'
        'Pros: flexible, rebalance without rehash.\n'
        'Cons: lookup service is bottleneck / SPOF.'
    )
    pdf.subsection("Geographic")
    pdf.body_text(
        'US users -> US shard, EU -> EU shard.\n'
        'Pros: data locality, compliance (GDPR).\n'
        'Cons: cross-region queries expensive.'
    )
    pdf.subsection("Challenges")
    pdf.body_text(
        'JOINs across shards: very expensive, avoid.\n'
        'Cross-shard transactions: need 2PC (slow).\n'
        'Resharding: data migration required.\n'
        'Hot shards: uneven distribution.\n'
        'Auto-increment IDs: use Snowflake/UUIDs.\n'
        'Aggregations: scatter-gather across all shards.'
    )
    pdf.subsection("Best Practices")
    pdf.body_text(
        'Choose partition key carefully (high cardinality).\n'
        'Common keys: user_id, tenant_id, org_id.\n'
        'Avoid shard-crossing queries in data model.\n'
        'Use consistent hashing for minimal data movement.\n'
        'Do you NEED sharding? PG handles millions of rows\n'
        'with proper indexes. Shard when vertical is exhausted.'
    )

    # ── CONSISTENT HASHING ──
    pdf.section("Consistent Hashing")
    pdf.body_text(
        'Problem: hash(key) % N redistributes ALL keys when\n'
        'N changes.\n'
        'Solution: map keys and servers onto a ring (0..2^32).'
    )
    pdf.code_block(
        'Hash each server to a point on the ring.\n'
        'Hash each key to a point on the ring.\n'
        'Key assigned to next server clockwise.\n'
        'Add/remove server: only keys between it and\n'
        'predecessor are affected.'
    )
    pdf.subsection("Virtual Nodes")
    pdf.body_text(
        'Each server gets ~150 points on the ring.\n'
        'Even distribution with few physical servers.\n'
        'Removal spreads load across many (not just one).'
    )
    pdf.compact_list("Used in:", ["Cassandra", "DynamoDB", "consistent caching", "load balancers"])

    # ── DATABASE REPLICATION ──
    pdf.section("Database Replication")
    pdf.subsection("Single-Leader (Master-Slave)")
    pdf.body_text(
        'One primary handles writes, replicas handle reads.\n'
        'Replication lag: replicas slightly behind.\n'
        'Failover: promote replica on primary failure.'
    )
    pdf.subsection("Multi-Leader")
    pdf.body_text(
        'Multiple primaries accept writes (multi-region).\n'
        'Conflict resolution: last-write-wins, merge, custom.'
    )
    pdf.subsection("Leaderless (Dynamo-style)")
    pdf.body_text(
        'Any node accepts reads/writes. Quorum: R + W > N.\n'
        'Read repair + anti-entropy for sync.\n'
        'Used by: Cassandra, DynamoDB, Riak.'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 6 -- Distributed Systems Concepts
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Distributed Systems Concepts")

    # ── CAP ──
    pdf.section("CAP Theorem")
    pdf.body_text(
        'In a network partition, choose:'
    )
    pdf.code_block(
        'C (Consistency)  -- every read sees latest write\n'
        'A (Availability) -- every request gets a response\n'
        'P (Partition Tol) -- works despite network splits\n'
        '\n'
        'P is unavoidable -> real choice is CP vs AP\n'
        '\n'
        'CP: refuse requests if can\'t guarantee consistency\n'
        '    Postgres, MongoDB (default), ZooKeeper, etcd\n'
        'AP: serve potentially stale data, don\'t error out\n'
        '    Cassandra, DynamoDB, CouchDB'
    )

    # ── PACELC ──
    pdf.section("PACELC")
    pdf.body_text(
        'Extension of CAP for normal operation (no partition):\n'
        'PAC: during Partition -> Availability vs Consistency.\n'
        'ELC: Else (normal) -> Latency vs Consistency.\n'
        'DynamoDB = PA/EL (available, low latency).\n'
        'Postgres = PC/EC (consistent always).'
    )

    # ── DISTRIBUTED IDS ──
    pdf.section("Distributed ID Generation")
    pdf.subsection("Snowflake ID (Twitter)")
    pdf.code_block(
        '64 bits: [timestamp 41b][machine 10b][seq 12b]\n'
        'Sortable by time, 4096 IDs/ms/machine.\n'
        'No coordination between machines.'
    )
    pdf.subsection("UUID v4")
    pdf.body_text(
        '128 bits, random. No coordination.\n'
        'Not sortable, bad for B-tree indexes (random inserts).'
    )
    pdf.subsection("UUID v7 / ULID")
    pdf.body_text(
        'Time-sortable + random suffix.\n'
        'Better for DB indexes than v4.\n'
        'ULID: Crockford Base32, lexicographically sortable.'
    )

    # ── CONSISTENCY MODELS ──
    pdf.section("Consistency Models")
    pdf.subsection("Strong Consistency")
    pdf.body_text(
        'After write completes, all reads see that write.\n'
        'Expensive: requires coordination (consensus, quorum).'
    )
    pdf.subsection("Eventual Consistency")
    pdf.body_text(
        'Replicas converge "eventually" (ms to seconds).\n'
        'Reads may return stale data. Most distributed default.'
    )
    pdf.subsection("Causal Consistency")
    pdf.body_text(
        'If A causes B, everyone sees A before B.\n'
        'Concurrent ops may differ in order.\n'
        'Implemented with vector clocks / logical timestamps.'
    )
    pdf.subsection("Read-Your-Own-Writes")
    pdf.body_text(
        'User always sees own updates immediately.\n'
        'Others may see stale. Read from leader or sticky sessions.'
    )

    # ── CONSENSUS ──
    pdf.section("Consensus Protocols")
    pdf.subsection("Raft")
    pdf.body_text(
        'Leader election + log replication.\n'
        'Commits when majority ACK.\n'
        'Simpler than Paxos (etcd, CockroachDB, Consul).'
    )
    pdf.subsection("Paxos")
    pdf.body_text(
        'Proposers, Acceptors, Learners.\n'
        'Agreement if majority available.\n'
        'Hard to implement, Raft preferred.'
    )
    pdf.subsection("Two-Phase Commit (2PC)")
    pdf.body_text(
        'Coordinator -> Prepare (vote) -> Commit/Abort.\n'
        'Blocking: coordinator crash after Prepare = stuck.\n'
        'Used for distributed txns (cross-shard, cross-DB).'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 7 -- Scalability Patterns & Architecture
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Scalability Patterns & Architecture")

    # ── SCALING ──
    pdf.section("Scaling Strategies")
    pdf.subsection("Vertical (Scale Up)")
    pdf.body_text(
        'Bigger machine (more CPU, RAM, disk).\n'
        'Simple but has a ceiling. Good first step.'
    )
    pdf.subsection("Horizontal (Scale Out)")
    pdf.body_text(
        'More machines behind a load balancer.\n'
        'Requires stateless services (state in DB/Redis/S3).\n'
        'No ceiling in theory, adds complexity.'
    )

    # ── MICROSERVICES ──
    pdf.section("Microservices vs Monolith")
    pdf.subsection("Monolith")
    pdf.body_text(
        'Single deployable unit. Simpler dev/test/debug.\n'
        'Scales by running copies behind LB.\n'
        'Right for: small teams, early-stage, unclear boundaries.'
    )
    pdf.subsection("Microservices")
    pdf.body_text(
        'Each service owns data + logic, deployed independently.\n'
        'Communicate via REST/gRPC or events (Kafka).\n'
        'Independent scaling, deployment, tech stacks.\n'
        'Right for: large teams, clear domains, independent scale.'
    )
    pdf.subsection("Microservices Challenges")
    pdf.body_text(
        'Network latency between services.\n'
        'Distributed transactions (Saga pattern).\n'
        'Service discovery, observability (distributed tracing).\n'
        'Data consistency across services.\n'
        'Operational complexity (deploy/monitor N services).'
    )

    # ── SAGA ──
    pdf.section("Saga Pattern (Distributed Transactions)")
    pdf.body_text(
        'Sequence of local transactions, each publishes event.\n'
        'If step fails -> compensating transactions to undo.'
    )
    pdf.subsection("Choreography")
    pdf.body_text(
        'Each service listens and reacts (decoupled).\n'
        'Harder to debug, no central view.'
    )
    pdf.subsection("Orchestration")
    pdf.body_text(
        'Central coordinator directs the saga.\n'
        'Easier to understand, single point of control.'
    )

    # ── CIRCUIT BREAKER ──
    pdf.section("Circuit Breaker")
    pdf.body_text(
        'Downstream service failing -> don\'t keep hammering it.'
    )
    pdf.code_block(
        'Closed    -> requests flow, count failures\n'
        'Open      -> reject immediately (fail fast)\n'
        'Half-Open -> let a few through to test recovery'
    )
    pdf.body_text(
        'Prevents cascade failures.\n'
        'Gives downstream time to recover.'
    )

    # ── SERVICE MESH ──
    pdf.section("Service Mesh")
    pdf.body_text(
        'Infrastructure layer for svc-to-svc communication.\n'
        'Handles: mTLS, retries, circuit breaking, observability.\n'
        'Sidecar proxy (Envoy) per service.\n'
        'Examples: Istio, Linkerd.'
    )

    # ── ESTIMATION ──
    pdf.section("Back-of-Envelope Estimation")
    pdf.subsection("Key Numbers")
    pdf.code_block(
        '1 day  = 86,400s  ~ 10^5 s\n'
        '1 year = 31.5M s  ~ 3x10^7 s\n'
        '\n'
        '1 KB = 10^3    1 MB = 10^6\n'
        '1 GB = 10^9    1 TB = 10^12'
    )
    pdf.subsection("QPS Example")
    pdf.code_block(
        '100M DAU x 10 req/day = 1B req/day\n'
        '= 1B / 100K ~ 10K QPS avg\n'
        'Peak ~ 2-3x avg ~ 20-30K QPS'
    )
    pdf.subsection("Storage Example")
    pdf.code_block(
        '1M users x 1 KB profile = 1 GB\n'
        '1M users x 1 MB media   = 1 TB\n'
        '1B msgs/day x 100B = 100 GB/day ~ 36 TB/yr'
    )
    pdf.subsection("Latency Reference")
    pdf.code_block(
        'L1 cache          ~ 1 ns\n'
        'L2 cache          ~ 4 ns\n'
        'RAM               ~ 100 ns\n'
        'SSD random read   ~ 100 us\n'
        'HDD random read   ~ 10 ms\n'
        'Same DC round-trip ~ 0.5 ms\n'
        'Cross-continent   ~ 100-150 ms'
    )

    # ── AVAILABILITY ──
    pdf.section("Availability & SLA")
    pdf.code_block(
        '99%    -> 3.65 days downtime/year\n'
        '99.9%  -> 8.76 hours/year\n'
        '99.99% -> 52.6 minutes/year\n'
        '99.999% -> 5.26 minutes/year\n'
        '\n'
        'Series:   A -> B  = A x B (both must work)\n'
        'Parallel: A || B  = 1-(1-A)(1-B) (either works)'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 8 -- Observability & Security
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Observability & Security")

    # ── OBSERVABILITY ──
    pdf.section("Observability (Three Pillars)")
    pdf.subsection("Metrics")
    pdf.body_text(
        'Numeric time-series: counters, gauges, histograms.\n'
        'USE method (resources): Utilization, Saturation, Errors.\n'
        'RED method (services): Rate, Errors, Duration.\n'
        'Tools: Prometheus + Grafana, Datadog, CloudWatch.'
    )
    pdf.subsection("Logging")
    pdf.body_text(
        'Structured logs (JSON) with correlation IDs.\n'
        'Levels: DEBUG, INFO, WARN, ERROR.\n'
        'Centralized: ELK (Elastic, Logstash, Kibana), Splunk.\n'
        'Include: timestamp, service, trace_id, request_id.'
    )
    pdf.subsection("Tracing (Distributed)")
    pdf.body_text(
        'Follow request across multiple services.\n'
        'Each service adds a span to the trace.\n'
        'Propagate trace_id via headers (W3C Trace Context).\n'
        'Tools: Jaeger, Zipkin, AWS X-Ray, OpenTelemetry.'
    )
    pdf.subsection("Alerting")
    pdf.body_text(
        'Alert on symptoms, not causes (error rate > CPU).\n'
        'SLO-based alerts: burn rate exceeds threshold.\n'
        'PagerDuty, OpsGenie for on-call routing.'
    )

    # ── AUTH ──
    pdf.section("Authentication & Authorization")
    pdf.subsection("JWT (JSON Web Token)")
    pdf.body_text(
        'Stateless: token has claims, signed by server.\n'
        'Header.Payload.Signature (Base64).\n'
        'No server-side session storage needed.\n'
        'Downside: can\'t revoke until expiry (short TTL + refresh).'
    )
    pdf.subsection("OAuth 2.0 Flow")
    pdf.code_block(
        '1. User -> auth provider (Google, GitHub)\n'
        '2. User grants permission\n'
        '3. Provider returns auth code\n'
        '4. Backend exchanges code -> access + refresh token\n'
        '5. Backend calls provider API with access_token\n'
        '6. Issue your own JWT/session to user'
    )
    pdf.subsection("Session-Based")
    pdf.body_text(
        'Server stores session in Redis/DB.\n'
        'Client holds session_id cookie.\n'
        'Stateful but revocable, simpler.'
    )
    pdf.subsection("Authorization Models")
    pdf.compact_list("RBAC:", ["Role-Based (admin, editor, viewer)"])
    pdf.compact_list("ABAC:", ["Attribute-Based (dept=eng AND level>=5)"])
    pdf.compact_list("ACL:", ["Access Control Lists (per-resource permissions)"])

    # ── SECURITY ──
    pdf.section("Security Considerations")
    pdf.body_text(
        'HTTPS everywhere (TLS termination at LB/edge).\n'
        'Input validation at API boundary.\n'
        'Rate limiting to prevent abuse.\n'
        'SQL injection: parameterized queries.\n'
        'CORS: restrict allowed origins.\n'
        'Secrets: Vault, AWS Secrets Manager (never in code).\n'
        'Encryption at rest (DB, S3) and in transit (TLS).\n'
        'Principle of least privilege for svc-to-svc auth.'
    )

    # ══════════════════════════════════════════════════════════
    #  PAGE 9 -- Interview Framework & Common Problems
    # ══════════════════════════════════════════════════════════
    pdf.new_page("Interview Framework & Common Problems")

    # ── FRAMEWORK ──
    pdf.section("System Design Interview Framework")
    pdf.subsection("Step 1: Requirements (3-5 min)")
    pdf.body_text(
        'Functional: what does the system DO? (core features).\n'
        'Non-functional: scale, latency, availability, consistency.\n'
        'Ask: DAU? Read/write ratio? Data size? Geo distribution?\n'
        'Scope: what is in vs out for this interview?'
    )
    pdf.subsection("Step 2: Estimation (3-5 min)")
    pdf.body_text(
        'QPS (average and peak), storage (per day/year),\n'
        'bandwidth, cache size needed.'
    )
    pdf.subsection("Step 3: High-Level Design (10-15 min)")
    pdf.body_text(
        'Draw: Client -> CDN -> LB -> API GW -> Services -> DB.\n'
        'Identify core services and responsibilities.\n'
        'Choose data store(s), caching, queuing.'
    )
    pdf.subsection("Step 4: Detailed Design (10-15 min)")
    pdf.body_text(
        'Deep dive 2-3 critical components.\n'
        'Data model: tables, keys, indexes, access patterns.\n'
        'API design: key endpoints, request/response.\n'
        'Discuss trade-offs for each decision.'
    )
    pdf.subsection("Step 5: Bottlenecks & Scale (5 min)")
    pdf.body_text(
        'Single points of failure? Redundancy.\n'
        'Hot spots? Distribute load.\n'
        'What happens at 10x, 100x? Monitoring & alerting.'
    )

    # ── COMMON PROBLEMS ──
    pdf.section("Common Design Problems")

    pdf.subsection("URL Shortener")
    pdf.body_text(
        'Write: hash long URL -> store mapping.\n'
        'Read: lookup short code -> redirect 301/302.\n'
        'Read-heavy: cache-aside with Redis, shard by code.\n'
        'Handle: hash collisions, analytics, expiration.'
    )
    pdf.subsection("Chat System (WhatsApp/Slack)")
    pdf.body_text(
        'WebSocket for real-time delivery.\n'
        'Store in Cassandra (write-heavy, partition by chat_id).\n'
        'Online presence: heartbeat + Redis pub/sub.\n'
        'Push notifications for offline users.\n'
        'Group: fan-out on write vs fan-out on read.'
    )
    pdf.subsection("News Feed (Twitter/Instagram)")
    pdf.body_text(
        'Fan-out on write: pre-compute feed (fast read).\n'
        'Fan-out on read: assemble at read time (simple write).\n'
        'Hybrid: write for normal users, read for celebrities.\n'
        'Store: Redis sorted set for feed, Postgres for posts.'
    )
    pdf.subsection("Notification System")
    pdf.body_text(
        'Kafka for event ingestion.\n'
        'Template, user preferences, dedup.\n'
        'Delivery: push (APNs/FCM), email (SES), SMS, in-app.\n'
        'Priority queue, rate limiting per user/channel.'
    )
    pdf.subsection("Rate Limiter")
    pdf.body_text(
        'Token bucket or sliding window.\n'
        'Redis: INCR + EXPIRE for distributed limiting.\n'
        'Key by: user_id, IP, API key.\n'
        'Return 429 with Retry-After header.'
    )
    pdf.subsection("Distributed File Storage (S3-like)")
    pdf.body_text(
        'Metadata service: file info -> SQL DB.\n'
        'Block storage: chunk files, replicate across nodes.\n'
        'Consistent hashing for chunk placement.\n'
        'Erasure coding for durability (vs 3x replication).'
    )
    pdf.subsection("Search Autocomplete")
    pdf.body_text(
        'Trie for prefix matching.\n'
        'Precompute top suggestions per prefix.\n'
        'Update async via MapReduce on search logs.\n'
        'Cache hot prefixes in Redis, CDN for common ones.'
    )
    pdf.subsection("Ride-Sharing (Uber/Lyft)")
    pdf.body_text(
        'Geospatial index: QuadTree or Geohash.\n'
        'Match rider to nearest available driver.\n'
        'Real-time location: WebSocket or frequent polling.\n'
        'ETA: Dijkstra + historical traffic.\n'
        'Surge pricing: supply/demand per geo region.'
    )
    pdf.subsection("Video Streaming (YouTube/Netflix)")
    pdf.body_text(
        'Upload: chunk, transcode to multiple resolutions.\n'
        'CDN: serve chunks from edge (most traffic).\n'
        'Adaptive bitrate: client switches on bandwidth.\n'
        'Metadata: Postgres. View counts: Kafka -> Cassandra.'
    )

    # ── OUTPUT ──
    out_dir = os.path.dirname(os.path.abspath(__file__))
    out_path = os.path.join(out_dir, "SystemDesign_QuickRef.pdf")
    pdf.output(out_path)
    print(f"Generated: {out_path}")


if __name__ == "__main__":
    build()
