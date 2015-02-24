------------------
-- test table
------------------
CREATE SEQUENCE test_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

CREATE TABLE test (
                id BIGINT NOT NULL DEFAULT nextval('test_seq'),
                name VARCHAR,
                start_date DATE,
                end_date DATE,
                created_at DATE,
                created_by VARCHAR,
                updated_at DATE,
                updated_by VARCHAR,
                CONSTRAINT test_pk PRIMARY KEY (id)
);
COMMENT ON TABLE test IS 'general data for the test';
ALTER SEQUENCE test_seq OWNED BY test.id;

