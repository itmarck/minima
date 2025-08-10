
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  entity_kind TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  occurred_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS records (
  id TEXT PRIMARY KEY,
  event_id TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  entity_kind TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);


-- Local Registry
CREATE TABLE logs (
  id TEXT PRIMARY KEY, -- UUID
  level TEXT NOT NULL, -- 'info', 'warn', 'error', etc.
  message TEXT NOT NULL,
  context TEXT, -- JSON with optional metadata
  created_at INTEGER NOT NULL -- UTC timestamp
);

-- Profile information (one row only)
CREATE TABLE profiles (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  display_name TEXT DEFAULT 'Local',
  node TEXT, -- UUID generated for this device
  tailscale_id TEXT, -- Tailscale device identifier for this device
  tailscale_token TEXT -- Tailscale access token
);

INSERT INTO profiles DEFAULT VALUES;
