\set ON_ERROR_STOP 1
BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------

CREATE TABLE edit_event
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    event               INTEGER NOT NULL  -- PK, references event.id CASCADE
);

CREATE TABLE event ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    time                TIME WITHOUT TIME ZONE,
    type                INTEGER, -- references event_type.id
    cancelled           BOOLEAN NOT NULL DEFAULT FALSE,
    setlist             TEXT,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CONSTRAINT event_ended_check CHECK (
        (
          -- If any end date fields are not null, then ended must be true
          (end_date_year IS NOT NULL OR
           end_date_month IS NOT NULL OR
           end_date_day IS NOT NULL) AND
          ended = TRUE
        ) OR (
          -- Otherwise, all end date fields must be null
          (end_date_year IS NULL AND
           end_date_month IS NULL AND
           end_date_day IS NULL)
        )
      )
);

CREATE TABLE event_tag_raw (
    event               INTEGER NOT NULL, -- PK, references event.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE event_alias_type ( -- replicate
    id SERIAL,
    name TEXT NOT NULL,
    parent              INTEGER, -- references event_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE event_alias ( -- replicate (verbose)
    id                  SERIAL,
    event               INTEGER NOT NULL, -- references event.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references event_alias_type.id
    sort_name           VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    primary_for_locale  BOOLEAN NOT NULL DEFAULT false,
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CHECK (
        (
          -- If any end date fields are not null, then ended must be true
          (end_date_year IS NOT NULL OR
           end_date_month IS NOT NULL OR
           end_date_day IS NOT NULL) AND
          ended = TRUE
        ) OR (
          -- Otherwise, all end date fields must be null
          (end_date_year IS NULL AND
           end_date_month IS NULL AND
           end_date_day IS NULL)
        )
      ),
    CONSTRAINT primary_check CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)),
    CONSTRAINT search_hints_are_empty
      CHECK (
        (type <> 2) OR (
          type = 2 AND sort_name = name AND
          begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
          end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
          primary_for_locale IS FALSE AND locale IS NULL
        )
      )
);

CREATE TABLE event_annotation ( -- replicate (verbose)
    event               INTEGER NOT NULL, -- PK, references event.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE event_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references event.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE event_tag ( -- replicate (verbose)
    event               INTEGER NOT NULL, -- PK, references event.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE event_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references event_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE l_area_event ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references event.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_artist_event ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references event.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_event ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references event.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_instrument ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_event_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_area_event_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_event.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_event_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_event.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_event_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_event.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_event_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

-----------------------
-- CREATE NEW VIEWS  --
-----------------------

CREATE OR REPLACE VIEW event_series AS
    SELECT entity0 AS event,
           entity1 AS series,
           lrs.id AS relationship,
           link_order,
           lrs.link,
           COALESCE(text_value, '') AS text_value
    FROM l_event_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '707d947d-9563-328a-9a7d-0c5b9c3a9791')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- new relationship types
SELECT setval('link_type_id_seq', (SELECT MAX(id) FROM link_type));
SELECT setval('link_attribute_type_id_seq', (SELECT MAX(id) FROM link_attribute_type));

\set EVENT_PART_OF_SERIES_GID 'generate_uuid_v3(''6ba7b8119dad11d180b400c04fd430c8'', ''http://musicbrainz.org/linktype/event/series/part_of'')'

INSERT INTO link_type (gid, entity_type0, entity_type1, entity0_cardinality,
                       entity1_cardinality, name, description, link_phrase,
                       reverse_link_phrase, long_link_phrase) VALUES
    (
        :EVENT_PART_OF_SERIES_GID,
        'event', 'series', 0, 0, 'part of',
        'Indicates that the event is part of a series.',
        'part of', 'has parts', 'is a part of'
    )
    RETURNING id, gid, entity_type0, entity_type1, name, long_link_phrase;

INSERT INTO orderable_link_type (link_type, direction) VALUES
    ((SELECT id FROM link_type WHERE gid = :EVENT_PART_OF_SERIES_GID), 2);

INSERT INTO series_type (name, entity_type, parent, child_order, description) VALUES
    ('Event', 'event', NULL, 5, 'Indicates that the series is of events.');

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES
    ((SELECT id FROM link_type WHERE gid = :EVENT_PART_OF_SERIES_GID),
     (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'),
     0, 1
    );

\unset EVENT_PART_OF_SERIES_GID

--------------------
-- CREATE INDEXES --
--------------------

ALTER TABLE documentation.l_area_event_example ADD CONSTRAINT l_area_event_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_artist_event_example ADD CONSTRAINT l_artist_event_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_event_example ADD CONSTRAINT l_event_event_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_instrument_example ADD CONSTRAINT l_event_instrument_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_label_example ADD CONSTRAINT l_event_label_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_place_example ADD CONSTRAINT l_event_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_recording_example ADD CONSTRAINT l_event_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_release_group_example ADD CONSTRAINT l_event_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_release_example ADD CONSTRAINT l_event_release_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_series_example ADD CONSTRAINT l_event_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_url_example ADD CONSTRAINT l_event_url_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_work_example ADD CONSTRAINT l_event_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_area_event ADD CONSTRAINT l_area_event_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_event ADD CONSTRAINT l_artist_event_pkey PRIMARY KEY (id);
ALTER TABLE l_event_event ADD CONSTRAINT l_event_event_pkey PRIMARY KEY (id);
ALTER TABLE l_event_instrument ADD CONSTRAINT l_event_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_event_label ADD CONSTRAINT l_event_label_pkey PRIMARY KEY (id);
ALTER TABLE l_event_place ADD CONSTRAINT l_event_place_pkey PRIMARY KEY (id);
ALTER TABLE l_event_recording ADD CONSTRAINT l_event_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_event_release_group ADD CONSTRAINT l_event_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_event_release ADD CONSTRAINT l_event_release_pkey PRIMARY KEY (id);
ALTER TABLE l_event_series ADD CONSTRAINT l_event_series_pkey PRIMARY KEY (id);
ALTER TABLE l_event_url ADD CONSTRAINT l_event_url_pkey PRIMARY KEY (id);
ALTER TABLE l_event_work ADD CONSTRAINT l_event_work_pkey PRIMARY KEY (id);

ALTER TABLE edit_event ADD CONSTRAINT edit_event_pkey PRIMARY KEY (edit, event);

ALTER TABLE event ADD CONSTRAINT event_pkey PRIMARY KEY (id);
ALTER TABLE event_alias ADD CONSTRAINT event_alias_pkey PRIMARY KEY (id);
ALTER TABLE event_alias_type ADD CONSTRAINT event_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE event_annotation ADD CONSTRAINT event_annotation_pkey PRIMARY KEY (event, annotation);
ALTER TABLE event_gid_redirect ADD CONSTRAINT event_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE event_tag ADD CONSTRAINT event_tag_pkey PRIMARY KEY (event, tag);
ALTER TABLE event_tag_raw ADD CONSTRAINT event_tag_raw_pkey PRIMARY KEY (event, editor, tag);
ALTER TABLE event_type ADD CONSTRAINT event_type_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX l_area_event_idx_uniq ON l_area_event (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_event_idx_uniq ON l_artist_event (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_event_idx_uniq ON l_event_event (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_instrument_idx_uniq ON l_event_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_label_idx_uniq ON l_event_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_place_idx_uniq ON l_event_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_recording_idx_uniq ON l_event_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_release_idx_uniq ON l_event_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_release_group_idx_uniq ON l_event_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_series_idx_uniq ON l_event_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_url_idx_uniq ON l_event_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_work_idx_uniq ON l_event_work (entity0, entity1, link, link_order);

CREATE INDEX l_area_event_idx_entity1 ON l_area_event (entity1);
CREATE INDEX l_artist_event_idx_entity1 ON l_artist_event (entity1);
CREATE INDEX l_event_event_idx_entity1 ON l_event_event (entity1);
CREATE INDEX l_event_instrument_idx_entity1 ON l_event_instrument (entity1);
CREATE INDEX l_event_label_idx_entity1 ON l_event_label (entity1);
CREATE INDEX l_event_place_idx_entity1 ON l_event_place (entity1);
CREATE INDEX l_event_recording_idx_entity1 ON l_event_recording (entity1);
CREATE INDEX l_event_release_idx_entity1 ON l_event_release (entity1);
CREATE INDEX l_event_release_group_idx_entity1 ON l_event_release_group (entity1);
CREATE INDEX l_event_series_idx_entity1 ON l_event_series (entity1);
CREATE INDEX l_event_url_idx_entity1 ON l_event_url (entity1);
CREATE INDEX l_event_work_idx_entity1 ON l_event_work (entity1);

CREATE UNIQUE INDEX event_idx_gid ON event (gid);
CREATE INDEX event_idx_name ON event (name);

CREATE UNIQUE INDEX event_idx_null_comment ON event (name) WHERE comment IS NULL;
CREATE UNIQUE INDEX event_idx_uniq_name_comment ON event (name, comment) WHERE comment IS NOT NULL;

CREATE INDEX event_alias_idx_event ON event_alias (event);
CREATE UNIQUE INDEX event_alias_idx_primary ON event_alias (event, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX event_tag_idx_tag ON event_tag (tag);

CREATE INDEX event_tag_raw_idx_tag ON event_tag_raw (tag);
CREATE INDEX event_tag_raw_idx_editor ON event_tag_raw (editor);

CREATE INDEX edit_event_idx ON edit_event (event);

---------------------
-- UPDATE FUNCTIONS--
---------------------

CREATE OR REPLACE FUNCTION empty_artists() RETURNS SETOF int AS
$BODY$
  SELECT id FROM artist
  WHERE
    id > 2 AND
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT artist FROM edit_artist WHERE edit_artist.status = 1
  EXCEPT
  SELECT artist FROM artist_credit_name
  EXCEPT
  SELECT entity1 FROM l_area_artist
  EXCEPT
  SELECT entity0 FROM l_artist_artist
  EXCEPT
  SELECT entity1 FROM l_artist_artist
  EXCEPT
  SELECT entity0 FROM l_artist_event
  EXCEPT
  SELECT entity0 FROM l_artist_instrument
  EXCEPT
  SELECT entity0 FROM l_artist_label
  EXCEPT
  SELECT entity0 FROM l_artist_place
  EXCEPT
  SELECT entity0 FROM l_artist_recording
  EXCEPT
  SELECT entity0 FROM l_artist_release
  EXCEPT
  SELECT entity0 FROM l_artist_release_group
  EXCEPT
  SELECT entity0 FROM l_artist_series
  EXCEPT
  SELECT entity0 FROM l_artist_url
  EXCEPT
  SELECT entity0 FROM l_artist_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_labels() RETURNS SETOF int AS
$BODY$
  SELECT id FROM label
  WHERE
    id > 1 AND
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT label FROM edit_label WHERE edit_label.status = 1
  EXCEPT
  SELECT label FROM release_label
  EXCEPT
  SELECT entity1 FROM l_area_label
  EXCEPT
  SELECT entity1 FROM l_artist_label
  EXCEPT
  SELECT entity1 FROM l_event_label
  EXCEPT
  SELECT entity1 FROM l_instrument_label
  EXCEPT
  SELECT entity1 FROM l_label_label
  EXCEPT
  SELECT entity0 FROM l_label_label
  EXCEPT
  SELECT entity0 FROM l_label_place
  EXCEPT
  SELECT entity0 FROM l_label_recording
  EXCEPT
  SELECT entity0 FROM l_label_release
  EXCEPT
  SELECT entity0 FROM l_label_release_group
  EXCEPT
  SELECT entity0 FROM l_label_series
  EXCEPT
  SELECT entity0 FROM l_label_url
  EXCEPT
  SELECT entity0 FROM l_label_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_release_groups() RETURNS SETOF int AS
$BODY$
  SELECT id FROM release_group
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT release_group
  FROM edit_release_group
  JOIN edit ON (edit.id = edit_release_group.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT release_group FROM release
  EXCEPT
  SELECT entity1 FROM l_area_release_group
  EXCEPT
  SELECT entity1 FROM l_artist_release_group
  EXCEPT
  SELECT entity1 FROM l_event_release_group
  EXCEPT
  SELECT entity1 FROM l_instrument_release_group
  EXCEPT
  SELECT entity1 FROM l_label_release_group
  EXCEPT
  SELECT entity1 FROM l_place_release_group
  EXCEPT
  SELECT entity1 FROM l_recording_release_group
  EXCEPT
  SELECT entity1 FROM l_release_release_group
  EXCEPT
  SELECT entity1 FROM l_release_group_release_group
  EXCEPT
  SELECT entity0 FROM l_release_group_release_group
  EXCEPT
  SELECT entity0 FROM l_release_group_series
  EXCEPT
  SELECT entity0 FROM l_release_group_url
  EXCEPT
  SELECT entity0 FROM l_release_group_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_works() RETURNS SETOF int AS
$BODY$
  SELECT id FROM work
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT work
  FROM edit_work
  JOIN edit ON (edit.id = edit_work.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT entity1 FROM l_area_work
  EXCEPT
  SELECT entity1 FROM l_artist_work
  EXCEPT
  SELECT entity1 FROM l_event_work
  EXCEPT
  SELECT entity1 FROM l_instrument_work
  EXCEPT
  SELECT entity1 FROM l_label_work
  EXCEPT
  SELECT entity1 FROM l_place_work
  EXCEPT
  SELECT entity1 FROM l_recording_work
  EXCEPT
  SELECT entity1 FROM l_release_work
  EXCEPT
  SELECT entity1 FROM l_release_group_work
  EXCEPT
  SELECT entity1 FROM l_series_work
  EXCEPT
  SELECT entity1 FROM l_url_work
  EXCEPT
  SELECT entity1 FROM l_work_work
  EXCEPT
  SELECT entity0 FROM l_work_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_places() RETURNS SETOF int AS
$BODY$
  SELECT id FROM place
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT place
  FROM edit_place
  JOIN edit ON (edit.id = edit_place.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT entity1 FROM l_area_place
  EXCEPT
  SELECT entity1 FROM l_artist_place
  EXCEPT
  SELECT entity1 FROM l_event_place
  EXCEPT
  SELECT entity1 FROM l_instrument_place
  EXCEPT
  SELECT entity1 FROM l_label_place
  EXCEPT
  SELECT entity1 FROM l_place_place
  EXCEPT
  SELECT entity0 FROM l_place_place
  EXCEPT
  SELECT entity0 FROM l_place_recording
  EXCEPT
  SELECT entity0 FROM l_place_release
  EXCEPT
  SELECT entity0 FROM l_place_release_group
  EXCEPT
  SELECT entity0 FROM l_place_series
  EXCEPT
  SELECT entity0 FROM l_place_url
  EXCEPT
  SELECT entity0 FROM l_place_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_series() RETURNS SETOF int AS
$BODY$
  SELECT id FROM series
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT series
  FROM edit_series
  JOIN edit ON (edit.id = edit_series.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT entity1 FROM l_area_series
  EXCEPT
  SELECT entity1 FROM l_artist_series
  EXCEPT
  SELECT entity1 FROM l_event_series
  EXCEPT
  SELECT entity1 FROM l_instrument_series
  EXCEPT
  SELECT entity1 FROM l_label_series
  EXCEPT
  SELECT entity1 FROM l_place_series
  EXCEPT
  SELECT entity1 FROM l_recording_series
  EXCEPT
  SELECT entity1 FROM l_release_series
  EXCEPT
  SELECT entity1 FROM l_release_group_series
  EXCEPT
  SELECT entity0 FROM l_series_series
  EXCEPT
  SELECT entity1 FROM l_series_series
  EXCEPT
  SELECT entity0 FROM l_series_url
  EXCEPT
  SELECT entity0 FROM l_series_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION empty_events() RETURNS SETOF int AS
$BODY$
  SELECT id FROM event
  WHERE
    edits_pending = 0 AND
    (
      last_updated < now() - '1 day'::interval OR last_updated is NULL
    )
  EXCEPT
  SELECT event
  FROM edit_event
  JOIN edit ON (edit.id = edit_event.edit)
  WHERE edit.status = 1
  EXCEPT
  SELECT entity1 FROM l_area_event
  EXCEPT
  SELECT entity1 FROM l_artist_event
  EXCEPT
  SELECT entity1 FROM l_event_event
  EXCEPT
  SELECT entity0 FROM l_event_event
  EXCEPT
  SELECT entity0 FROM l_event_instrument
  EXCEPT
  SELECT entity0 FROM l_event_label
  EXCEPT
  SELECT entity0 FROM l_event_place
  EXCEPT
  SELECT entity0 FROM l_event_recording
  EXCEPT
  SELECT entity0 FROM l_event_release
  EXCEPT
  SELECT entity0 FROM l_event_release_group
  EXCEPT
  SELECT entity0 FROM l_event_series
  EXCEPT
  SELECT entity0 FROM l_event_url
  EXCEPT
  SELECT entity0 FROM l_event_work;
$BODY$
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION delete_unused_url(ids INTEGER[])
RETURNS VOID AS $$
DECLARE
  clear_up INTEGER[];
BEGIN
  SELECT ARRAY(
    SELECT id FROM url url_row WHERE id = any(ids)
    AND NOT (
      EXISTS (
        SELECT TRUE FROM l_area_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_artist_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_event_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_instrument_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_label_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_place_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_recording_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_release_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_release_group_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_series_url
        WHERE entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_url_url
        WHERE entity0 = url_row.id OR entity1 = url_row.id
        LIMIT 1
      ) OR
      EXISTS (
        SELECT TRUE FROM l_url_work
        WHERE entity0 = url_row.id
        LIMIT 1
      )
    )
  ) INTO clear_up;

  DELETE FROM url_gid_redirect WHERE new_id = any(clear_up);
  DELETE FROM url WHERE id = any(clear_up);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_orphaned_recordings()
RETURNS TRIGGER
AS $$
  BEGIN
    PERFORM TRUE
    FROM recording outer_r
    WHERE id = OLD.recording
      AND edits_pending = 0
      AND NOT EXISTS (
        SELECT TRUE
        FROM edit JOIN edit_recording er ON edit.id = er.edit
        WHERE er.recording = outer_r.id
          AND type IN (71, 207, 218)
          LIMIT 1
      ) AND NOT EXISTS (
        SELECT TRUE FROM track WHERE track.recording = outer_r.id LIMIT 1
      ) AND NOT EXISTS (
        SELECT TRUE FROM l_area_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_artist_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_event_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_instrument_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_label_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_place_recording WHERE entity1 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_recording WHERE entity1 = outer_r.id OR entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_release WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_release_group WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_series WHERE entity0 = outer_r.id
          UNION ALL
        SELECT TRUE FROM l_recording_work WHERE entity0 = outer_r.id
          UNION ALL
         SELECT TRUE FROM l_recording_url WHERE entity0 = outer_r.id
      );

    IF FOUND THEN
      -- Remove references from tables that don't change whether or not this recording
      -- is orphaned.
      DELETE FROM isrc WHERE recording = OLD.recording;
      DELETE FROM recording_annotation WHERE recording = OLD.recording;
      DELETE FROM recording_gid_redirect WHERE new_id = OLD.recording;
      DELETE FROM recording_rating_raw WHERE recording = OLD.recording;
      DELETE FROM recording_tag WHERE recording = OLD.recording;
      DELETE FROM recording_tag_raw WHERE recording = OLD.recording;

      DELETE FROM recording WHERE id = OLD.recording;
    END IF;

    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

COMMIT;
