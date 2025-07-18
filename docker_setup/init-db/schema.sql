--
-- PostgreSQL database dump
--

-- Dumped from database version 15.12 (Debian 15.12-1.pgdg120+1)
-- Dumped by pg_dump version 15.12 (Debian 15.12-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: n8n_chat_histories; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.n8n_chat_histories (
    id integer NOT NULL,
    session_id text NOT NULL,
    message jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.n8n_chat_histories OWNER TO n8n;

--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.n8n_chat_histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.n8n_chat_histories_id_seq OWNER TO n8n;

--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.n8n_chat_histories_id_seq OWNED BY public.n8n_chat_histories.id;


--
-- Name: n8n_vector_collections; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.n8n_vector_collections (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    cmetadata jsonb
);


ALTER TABLE public.n8n_vector_collections OWNER TO n8n;

--
-- Name: n8n_vectors; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.n8n_vectors (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    text text,
    metadata jsonb,
    embedding public.vector,
    collection_id uuid
);


ALTER TABLE public.n8n_vectors OWNER TO n8n;

--
-- Name: presentation_slides; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.presentation_slides (
    id integer NOT NULL,
    presentation_id uuid NOT NULL,
    slide_number integer NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    feedback text,
    slide_good_enough boolean
);


ALTER TABLE public.presentation_slides OWNER TO n8n;

--
-- Name: presentation_slides_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.presentation_slides_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.presentation_slides_id_seq OWNER TO n8n;

--
-- Name: presentation_slides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.presentation_slides_id_seq OWNED BY public.presentation_slides.id;


--
-- Name: presentations; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.presentations (
    presentation_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.presentations OWNER TO n8n;

--
-- Name: n8n_chat_histories id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.n8n_chat_histories ALTER COLUMN id SET DEFAULT nextval('public.n8n_chat_histories_id_seq'::regclass);


--
-- Name: presentation_slides id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.presentation_slides ALTER COLUMN id SET DEFAULT nextval('public.presentation_slides_id_seq'::regclass);


--
-- Name: n8n_chat_histories n8n_chat_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.n8n_chat_histories
    ADD CONSTRAINT n8n_chat_histories_pkey PRIMARY KEY (id);


--
-- Name: n8n_vector_collections n8n_vector_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.n8n_vector_collections
    ADD CONSTRAINT n8n_vector_collections_pkey PRIMARY KEY (uuid);


--
-- Name: n8n_vectors n8n_vectors_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.n8n_vectors
    ADD CONSTRAINT n8n_vectors_pkey PRIMARY KEY (id);


--
-- Name: presentation_slides presentation_slides_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.presentation_slides
    ADD CONSTRAINT presentation_slides_pkey PRIMARY KEY (id);


--
-- Name: presentation_slides presentation_slides_presentation_id_slide_number_key; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.presentation_slides
    ADD CONSTRAINT presentation_slides_presentation_id_slide_number_key UNIQUE (presentation_id, slide_number);


--
-- Name: presentations presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.presentations
    ADD CONSTRAINT presentations_pkey PRIMARY KEY (presentation_id);


--
-- Name: idx_n8n_vector_collections_name; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_n8n_vector_collections_name ON public.n8n_vector_collections USING btree (name);


--
-- Name: n8n_vectors n8n_vectors_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.n8n_vectors
    ADD CONSTRAINT n8n_vectors_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.n8n_vector_collections(uuid) ON DELETE CASCADE;


--
-- Name: presentation_slides presentation_slides_presentation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.presentation_slides
    ADD CONSTRAINT presentation_slides_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES public.presentations(presentation_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

