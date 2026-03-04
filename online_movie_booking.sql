--
-- PostgreSQL database dump
--

\restrict J2O1WDT58CE4oGDF3mPxyFLK5IdWN88ejMEWbY3ddY09NEDjrlzS2uzpiZaFXXM

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: booking; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA booking;


ALTER SCHEMA booking OWNER TO postgres;

--
-- Name: check_show_overlap(); Type: FUNCTION; Schema: booking; Owner: postgres
--

CREATE FUNCTION booking.check_show_overlap() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM show s
        WHERE s.screen_id = NEW.screen_id
        AND NEW.start_time < s.end_time
        AND NEW.end_time > s.start_time
    ) THEN
        RAISE EXCEPTION 'Show timing overlaps on same screen';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION booking.check_show_overlap() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: booked_seat; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.booked_seat (
    booking_id integer NOT NULL,
    seat_id integer NOT NULL,
    show_id integer,
    price_at_booking numeric(10,2) NOT NULL
);


ALTER TABLE booking.booked_seat OWNER TO postgres;

--
-- Name: booking; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.booking (
    booking_id integer NOT NULL,
    user_id integer,
    show_id integer,
    booked_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(30),
    total_amount numeric(10,2),
    expires_at timestamp without time zone
);


ALTER TABLE booking.booking OWNER TO postgres;

--
-- Name: booking_booking_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.booking_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.booking_booking_id_seq OWNER TO postgres;

--
-- Name: booking_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.booking_booking_id_seq OWNED BY booking.booking.booking_id;


--
-- Name: city; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.city (
    city_id integer NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true
);


ALTER TABLE booking.city OWNER TO postgres;

--
-- Name: city_city_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.city_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.city_city_id_seq OWNER TO postgres;

--
-- Name: city_city_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.city_city_id_seq OWNED BY booking.city.city_id;


--
-- Name: genre; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.genre (
    genre_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE booking.genre OWNER TO postgres;

--
-- Name: genre_genre_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.genre_genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.genre_genre_id_seq OWNER TO postgres;

--
-- Name: genre_genre_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.genre_genre_id_seq OWNED BY booking.genre.genre_id;


--
-- Name: movie; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.movie (
    movie_id integer NOT NULL,
    title character varying(200) NOT NULL,
    language character varying(50),
    duration_minutes integer,
    certification character varying(10),
    release_date date,
    imdb_rating numeric(3,1),
    is_active boolean DEFAULT true,
    CONSTRAINT movie_duration_minutes_check CHECK ((duration_minutes > 0))
);


ALTER TABLE booking.movie OWNER TO postgres;

--
-- Name: movie_genre; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.movie_genre (
    movie_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE booking.movie_genre OWNER TO postgres;

--
-- Name: movie_movie_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.movie_movie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.movie_movie_id_seq OWNER TO postgres;

--
-- Name: movie_movie_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.movie_movie_id_seq OWNED BY booking.movie.movie_id;


--
-- Name: movie_person; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.movie_person (
    person_id integer NOT NULL,
    movie_id integer NOT NULL,
    role character varying(50) NOT NULL
);


ALTER TABLE booking.movie_person OWNER TO postgres;

--
-- Name: payment; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.payment (
    payment_id integer NOT NULL,
    booking_id integer,
    payment_method_id integer,
    amount numeric(10,2),
    status character varying(30),
    paid_at timestamp without time zone,
    gst_number character varying(50)
);


ALTER TABLE booking.payment OWNER TO postgres;

--
-- Name: payment_method; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.payment_method (
    payment_method_id integer NOT NULL,
    payment_method_desc character varying(100),
    active boolean DEFAULT true
);


ALTER TABLE booking.payment_method OWNER TO postgres;

--
-- Name: payment_method_payment_method_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.payment_method_payment_method_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.payment_method_payment_method_id_seq OWNER TO postgres;

--
-- Name: payment_method_payment_method_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.payment_method_payment_method_id_seq OWNED BY booking.payment_method.payment_method_id;


--
-- Name: payment_payment_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.payment_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.payment_payment_id_seq OWNER TO postgres;

--
-- Name: payment_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.payment_payment_id_seq OWNED BY booking.payment.payment_id;


--
-- Name: person; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.person (
    person_id integer NOT NULL,
    full_name character varying(150) NOT NULL,
    nationality character varying(100)
);


ALTER TABLE booking.person OWNER TO postgres;

--
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.person_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.person_person_id_seq OWNER TO postgres;

--
-- Name: person_person_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.person_person_id_seq OWNED BY booking.person.person_id;


--
-- Name: review; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.review (
    review_id integer NOT NULL,
    movie_id integer,
    user_id integer,
    rating integer,
    comment text,
    CONSTRAINT review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE booking.review OWNER TO postgres;

--
-- Name: review_review_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.review_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.review_review_id_seq OWNER TO postgres;

--
-- Name: review_review_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.review_review_id_seq OWNED BY booking.review.review_id;


--
-- Name: screen; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.screen (
    screen_id integer NOT NULL,
    theatre_id integer NOT NULL,
    screen_no integer NOT NULL,
    name character varying(100),
    capacity integer NOT NULL,
    sound_profile character varying(50),
    is_active boolean DEFAULT true,
    CONSTRAINT screen_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT screen_sound_profile_check CHECK (((sound_profile)::text = ANY ((ARRAY['NORMAL'::character varying, 'DOLBY'::character varying, 'IMAX'::character varying])::text[])))
);


ALTER TABLE booking.screen OWNER TO postgres;

--
-- Name: screen_screen_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.screen_screen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.screen_screen_id_seq OWNER TO postgres;

--
-- Name: screen_screen_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.screen_screen_id_seq OWNED BY booking.screen.screen_id;


--
-- Name: seat; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.seat (
    seat_id integer NOT NULL,
    screen_id integer NOT NULL,
    row_label character varying(10) NOT NULL,
    seat_no integer NOT NULL,
    seat_category_id integer NOT NULL
);


ALTER TABLE booking.seat OWNER TO postgres;

--
-- Name: seat_category; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.seat_category (
    seat_category_id integer NOT NULL,
    name character varying(50) NOT NULL,
    base_multiplier numeric(5,2) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true,
    CONSTRAINT seat_category_base_multiplier_check CHECK ((base_multiplier > (0)::numeric))
);


ALTER TABLE booking.seat_category OWNER TO postgres;

--
-- Name: seat_category_seat_category_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.seat_category_seat_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.seat_category_seat_category_id_seq OWNER TO postgres;

--
-- Name: seat_category_seat_category_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.seat_category_seat_category_id_seq OWNED BY booking.seat_category.seat_category_id;


--
-- Name: seat_seat_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.seat_seat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.seat_seat_id_seq OWNER TO postgres;

--
-- Name: seat_seat_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.seat_seat_id_seq OWNED BY booking.seat.seat_id;


--
-- Name: show; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.show (
    show_id integer NOT NULL,
    movie_id integer NOT NULL,
    screen_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    status character varying(30),
    base_price numeric(10,2),
    is_active boolean DEFAULT true,
    CONSTRAINT show_base_price_check CHECK ((base_price >= (0)::numeric)),
    CONSTRAINT show_check CHECK ((end_time > start_time))
);


ALTER TABLE booking.show OWNER TO postgres;

--
-- Name: show_seat_pricing; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.show_seat_pricing (
    show_id integer NOT NULL,
    seat_category_id integer NOT NULL,
    price numeric(10,2) NOT NULL,
    CONSTRAINT show_seat_pricing_price_check CHECK ((price > (0)::numeric))
);


ALTER TABLE booking.show_seat_pricing OWNER TO postgres;

--
-- Name: show_show_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.show_show_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.show_show_id_seq OWNER TO postgres;

--
-- Name: show_show_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.show_show_id_seq OWNED BY booking.show.show_id;


--
-- Name: theatre; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.theatre (
    theatre_id integer NOT NULL,
    city_id integer NOT NULL,
    name character varying(150) NOT NULL,
    address text,
    latitude numeric(9,6),
    longitude numeric(9,6),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true
);


ALTER TABLE booking.theatre OWNER TO postgres;

--
-- Name: theatre_theatre_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.theatre_theatre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.theatre_theatre_id_seq OWNER TO postgres;

--
-- Name: theatre_theatre_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.theatre_theatre_id_seq OWNED BY booking.theatre.theatre_id;


--
-- Name: users; Type: TABLE; Schema: booking; Owner: postgres
--

CREATE TABLE booking.users (
    user_id integer NOT NULL,
    full_name character varying(150),
    email character varying(150) NOT NULL,
    phone character varying(20),
    password_hash text NOT NULL,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role character varying(20) DEFAULT 'Customer',
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['Customer'::character varying, 'Admin'::character varying])::text[])))
);


ALTER TABLE booking.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: booking; Owner: postgres
--

CREATE SEQUENCE booking.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE booking.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: booking; Owner: postgres
--

ALTER SEQUENCE booking.users_user_id_seq OWNED BY booking.users.user_id;


--
-- Name: booking booking_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booking ALTER COLUMN booking_id SET DEFAULT nextval('booking.booking_booking_id_seq'::regclass);


--
-- Name: city city_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.city ALTER COLUMN city_id SET DEFAULT nextval('booking.city_city_id_seq'::regclass);


--
-- Name: genre genre_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.genre ALTER COLUMN genre_id SET DEFAULT nextval('booking.genre_genre_id_seq'::regclass);


--
-- Name: movie movie_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie ALTER COLUMN movie_id SET DEFAULT nextval('booking.movie_movie_id_seq'::regclass);


--
-- Name: payment payment_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.payment ALTER COLUMN payment_id SET DEFAULT nextval('booking.payment_payment_id_seq'::regclass);


--
-- Name: payment_method payment_method_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.payment_method ALTER COLUMN payment_method_id SET DEFAULT nextval('booking.payment_method_payment_method_id_seq'::regclass);


--
-- Name: person person_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.person ALTER COLUMN person_id SET DEFAULT nextval('booking.person_person_id_seq'::regclass);


--
-- Name: review review_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.review ALTER COLUMN review_id SET DEFAULT nextval('booking.review_review_id_seq'::regclass);


--
-- Name: screen screen_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.screen ALTER COLUMN screen_id SET DEFAULT nextval('booking.screen_screen_id_seq'::regclass);


--
-- Name: seat seat_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat ALTER COLUMN seat_id SET DEFAULT nextval('booking.seat_seat_id_seq'::regclass);


--
-- Name: seat_category seat_category_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat_category ALTER COLUMN seat_category_id SET DEFAULT nextval('booking.seat_category_seat_category_id_seq'::regclass);


--
-- Name: show show_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show ALTER COLUMN show_id SET DEFAULT nextval('booking.show_show_id_seq'::regclass);


--
-- Name: theatre theatre_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.theatre ALTER COLUMN theatre_id SET DEFAULT nextval('booking.theatre_theatre_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.users ALTER COLUMN user_id SET DEFAULT nextval('booking.users_user_id_seq'::regclass);


--
-- Data for Name: booked_seat; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.booked_seat (booking_id, seat_id, show_id, price_at_booking) FROM stdin;
1	1	1	250.00
2	15	1	350.00
\.


--
-- Data for Name: booking; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.booking (booking_id, user_id, show_id, booked_date, status, total_amount, expires_at) FROM stdin;
1	1	1	2026-02-22 17:37:27.430733	CONFIRMED	250.00	\N
2	2	1	2026-02-22 17:37:27.430733	CONFIRMED	350.00	\N
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.city (city_id, name, created_at, is_active) FROM stdin;
1	Pune	2026-02-22 17:28:13.589086	t
2	Mumbai	2026-02-22 17:28:13.589086	t
3	Bangalore	2026-02-22 17:28:13.589086	t
\.


--
-- Data for Name: genre; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.genre (genre_id, name) FROM stdin;
1	Sci-Fi
2	Action
3	Drama
4	Thriller
5	Crime
\.


--
-- Data for Name: movie; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.movie (movie_id, title, language, duration_minutes, certification, release_date, imdb_rating, is_active) FROM stdin;
1	Inception	English	148	UA	2010-07-16	8.8	t
2	Interstellar	English	169	UA	2014-11-07	8.6	t
3	Animal	Hindi	201	A	2023-12-01	7.2	t
4	Jawan	Hindi	165	UA	2023-09-07	7.0	t
5	KGF Chapter 2	Kannada	168	UA	2022-04-14	8.3	t
\.


--
-- Data for Name: movie_genre; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.movie_genre (movie_id, genre_id) FROM stdin;
1	1
1	4
2	1
2	3
3	2
3	3
4	2
5	2
5	5
\.


--
-- Data for Name: movie_person; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.movie_person (person_id, movie_id, role) FROM stdin;
1	1	ACTOR
2	1	ACTOR
2	2	DIRECTOR
3	3	ACTOR
3	4	DIRECTOR
4	5	ACTOR
5	5	DIRECTOR
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.payment (payment_id, booking_id, payment_method_id, amount, status, paid_at, gst_number) FROM stdin;
1	1	1	250.00	SUCCESS	2026-02-22 17:38:09.99915	\N
2	2	2	350.00	SUCCESS	2026-02-22 17:38:09.99915	\N
\.


--
-- Data for Name: payment_method; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.payment_method (payment_method_id, payment_method_desc, active) FROM stdin;
1	UPI	t
2	Credit Card	t
3	Debit Card	t
4	Net Banking	t
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.person (person_id, full_name, nationality) FROM stdin;
1	Leonardo DiCaprio	American
2	Christopher Nolan	British
3	Ranbir Kapoor	Indian
4	Sandeep Reddy Vanga	Indian
5	Shah Rukh Khan	Indian
6	Prashanth Neel	Indian
\.


--
-- Data for Name: review; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.review (review_id, movie_id, user_id, rating, comment) FROM stdin;
1	1	1	5	Amazing movie!
2	2	2	4	Great visuals and story.
\.


--
-- Data for Name: screen; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.screen (screen_id, theatre_id, screen_no, name, capacity, sound_profile, is_active) FROM stdin;
1	1	1	Screen 1	120	DOLBY	t
2	1	2	Screen 2	100	NORMAL	t
3	2	1	Audi 1	150	IMAX	t
4	3	1	Screen A	130	DOLBY	t
5	4	1	Screen Prime	110	NORMAL	t
\.


--
-- Data for Name: seat; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.seat (seat_id, screen_id, row_label, seat_no, seat_category_id) FROM stdin;
1	1	A	1	1
2	1	A	2	1
3	1	A	3	1
4	1	A	4	1
5	1	A	5	1
6	1	A	6	1
7	1	A	7	1
8	1	A	8	1
9	1	A	9	1
10	1	A	10	1
11	1	B	1	1
12	1	B	2	1
13	1	B	3	1
14	1	B	4	1
15	1	B	5	1
16	1	B	6	1
17	1	B	7	1
18	1	B	8	1
19	1	B	9	1
20	1	B	10	1
21	1	C	1	1
22	1	C	2	1
23	1	C	3	1
24	1	C	4	1
25	1	C	5	1
26	1	C	6	1
27	1	C	7	1
28	1	C	8	1
29	1	C	9	1
30	1	C	10	1
31	1	D	1	1
32	1	D	2	1
33	1	D	3	1
34	1	D	4	1
35	1	D	5	1
36	1	D	6	1
37	1	D	7	1
38	1	D	8	1
39	1	D	9	1
40	1	D	10	1
41	1	E	1	1
42	1	E	2	1
43	1	E	3	1
44	1	E	4	1
45	1	E	5	1
46	1	E	6	1
47	1	E	7	1
48	1	E	8	1
49	1	E	9	1
50	1	E	10	1
51	1	F	1	2
52	1	F	2	2
53	1	F	3	2
54	1	F	4	2
55	1	F	5	2
56	1	F	6	2
57	1	F	7	2
58	1	F	8	2
59	1	F	9	2
60	1	F	10	2
61	1	G	1	2
62	1	G	2	2
63	1	G	3	2
64	1	G	4	2
65	1	G	5	2
66	1	G	6	2
67	1	G	7	2
68	1	G	8	2
69	1	G	9	2
70	1	G	10	2
71	1	H	1	2
72	1	H	2	2
73	1	H	3	2
74	1	H	4	2
75	1	H	5	2
76	1	H	6	2
77	1	H	7	2
78	1	H	8	2
79	1	H	9	2
80	1	H	10	2
81	1	I	1	3
82	1	I	2	3
83	1	I	3	3
84	1	I	4	3
85	1	I	5	3
86	1	I	6	3
87	1	I	7	3
88	1	I	8	3
89	1	I	9	3
90	1	I	10	3
91	1	J	1	3
92	1	J	2	3
93	1	J	3	3
94	1	J	4	3
95	1	J	5	3
96	1	J	6	3
97	1	J	7	3
98	1	J	8	3
99	1	J	9	3
100	1	J	10	3
\.


--
-- Data for Name: seat_category; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.seat_category (seat_category_id, name, base_multiplier, description, created_at, updated_at, is_active) FROM stdin;
1	NORMAL	1.00	Standard seating	2026-02-22 17:27:54.62778	2026-02-22 17:27:54.62778	t
2	PREMIUM	1.50	Better view seating	2026-02-22 17:27:54.62778	2026-02-22 17:27:54.62778	t
3	RECLINER	2.00	Luxury recliner seats	2026-02-22 17:27:54.62778	2026-02-22 17:27:54.62778	t
\.


--
-- Data for Name: show; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.show (show_id, movie_id, screen_id, start_time, end_time, status, base_price, is_active) FROM stdin;
1	1	1	2026-03-01 10:00:00	2026-03-01 12:30:00	ACTIVE	250.00	t
2	2	1	2026-03-01 14:00:00	2026-03-01 17:00:00	ACTIVE	300.00	t
3	3	2	2026-03-01 11:00:00	2026-03-01 14:20:00	ACTIVE	220.00	t
4	4	3	2026-03-02 18:00:00	2026-03-02 21:00:00	ACTIVE	350.00	t
\.


--
-- Data for Name: show_seat_pricing; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.show_seat_pricing (show_id, seat_category_id, price) FROM stdin;
1	1	250.00
1	2	350.00
1	3	450.00
2	1	300.00
2	2	400.00
2	3	550.00
\.


--
-- Data for Name: theatre; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.theatre (theatre_id, city_id, name, address, latitude, longitude, created_at, is_active) FROM stdin;
1	1	PVR Phoenix Mall	Viman Nagar	18.567900	73.914300	2026-02-22 17:28:32.402098	t
2	1	Cinepolis Westend	Aundh	18.561200	73.807600	2026-02-22 17:28:32.402098	t
3	2	INOX R-City	Ghatkopar	19.086500	72.908100	2026-02-22 17:28:32.402098	t
4	3	PVR Orion Mall	Rajajinagar	12.991500	77.555000	2026-02-22 17:28:32.402098	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: booking; Owner: postgres
--

COPY booking.users (user_id, full_name, email, phone, password_hash, created_date, role) FROM stdin;
1	Ananya Joshi	ananya@email.com	9876543210	hashed1	2026-02-22 17:37:06.813166	Customer
2	Rahul Sharma	rahul@email.com	9123456780	hashed2	2026-02-22 17:37:06.813166	Customer
3	Admin User	admin@email.com	9999999999	hashed3	2026-02-22 17:37:06.813166	Admin
\.


--
-- Name: booking_booking_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.booking_booking_id_seq', 2, true);


--
-- Name: city_city_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.city_city_id_seq', 3, true);


--
-- Name: genre_genre_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.genre_genre_id_seq', 5, true);


--
-- Name: movie_movie_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.movie_movie_id_seq', 5, true);


--
-- Name: payment_method_payment_method_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.payment_method_payment_method_id_seq', 3, true);


--
-- Name: payment_payment_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.payment_payment_id_seq', 2, true);


--
-- Name: person_person_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.person_person_id_seq', 6, true);


--
-- Name: review_review_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.review_review_id_seq', 2, true);


--
-- Name: screen_screen_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.screen_screen_id_seq', 5, true);


--
-- Name: seat_category_seat_category_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.seat_category_seat_category_id_seq', 3, true);


--
-- Name: seat_seat_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.seat_seat_id_seq', 100, true);


--
-- Name: show_show_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.show_show_id_seq', 4, true);


--
-- Name: theatre_theatre_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.theatre_theatre_id_seq', 4, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: booking; Owner: postgres
--

SELECT pg_catalog.setval('booking.users_user_id_seq', 3, true);


--
-- Name: booked_seat booked_seat_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booked_seat
    ADD CONSTRAINT booked_seat_pkey PRIMARY KEY (booking_id, seat_id);


--
-- Name: booked_seat booked_seat_show_id_seat_id_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booked_seat
    ADD CONSTRAINT booked_seat_show_id_seat_id_key UNIQUE (show_id, seat_id);


--
-- Name: booking booking_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (booking_id);


--
-- Name: city city_name_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.city
    ADD CONSTRAINT city_name_key UNIQUE (name);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- Name: genre genre_name_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.genre
    ADD CONSTRAINT genre_name_key UNIQUE (name);


--
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (genre_id);


--
-- Name: movie_genre movie_genre_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie_genre
    ADD CONSTRAINT movie_genre_pkey PRIMARY KEY (movie_id, genre_id);


--
-- Name: movie_person movie_person_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie_person
    ADD CONSTRAINT movie_person_pkey PRIMARY KEY (person_id, movie_id, role);


--
-- Name: movie movie_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie
    ADD CONSTRAINT movie_pkey PRIMARY KEY (movie_id);


--
-- Name: payment_method payment_method_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.payment_method
    ADD CONSTRAINT payment_method_pkey PRIMARY KEY (payment_method_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- Name: review review_movie_id_user_id_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.review
    ADD CONSTRAINT review_movie_id_user_id_key UNIQUE (movie_id, user_id);


--
-- Name: review review_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (review_id);


--
-- Name: screen screen_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.screen
    ADD CONSTRAINT screen_pkey PRIMARY KEY (screen_id);


--
-- Name: screen screen_theatre_id_screen_no_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.screen
    ADD CONSTRAINT screen_theatre_id_screen_no_key UNIQUE (theatre_id, screen_no);


--
-- Name: seat_category seat_category_name_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat_category
    ADD CONSTRAINT seat_category_name_key UNIQUE (name);


--
-- Name: seat_category seat_category_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat_category
    ADD CONSTRAINT seat_category_pkey PRIMARY KEY (seat_category_id);


--
-- Name: seat seat_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat
    ADD CONSTRAINT seat_pkey PRIMARY KEY (seat_id);


--
-- Name: seat seat_screen_id_row_label_seat_no_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat
    ADD CONSTRAINT seat_screen_id_row_label_seat_no_key UNIQUE (screen_id, row_label, seat_no);


--
-- Name: show show_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show
    ADD CONSTRAINT show_pkey PRIMARY KEY (show_id);


--
-- Name: show_seat_pricing show_seat_pricing_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show_seat_pricing
    ADD CONSTRAINT show_seat_pricing_pkey PRIMARY KEY (show_id, seat_category_id);


--
-- Name: theatre theatre_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.theatre
    ADD CONSTRAINT theatre_pkey PRIMARY KEY (theatre_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_booked_seat_show; Type: INDEX; Schema: booking; Owner: postgres
--

CREATE INDEX idx_booked_seat_show ON booking.booked_seat USING btree (show_id);


--
-- Name: idx_booking_user; Type: INDEX; Schema: booking; Owner: postgres
--

CREATE INDEX idx_booking_user ON booking.booking USING btree (user_id);


--
-- Name: idx_seat_screen; Type: INDEX; Schema: booking; Owner: postgres
--

CREATE INDEX idx_seat_screen ON booking.seat USING btree (screen_id);


--
-- Name: idx_show_movie_time; Type: INDEX; Schema: booking; Owner: postgres
--

CREATE INDEX idx_show_movie_time ON booking.show USING btree (movie_id, start_time);


--
-- Name: idx_show_screen; Type: INDEX; Schema: booking; Owner: postgres
--

CREATE INDEX idx_show_screen ON booking.show USING btree (screen_id);


--
-- Name: show trigger_show_overlap; Type: TRIGGER; Schema: booking; Owner: postgres
--

CREATE TRIGGER trigger_show_overlap BEFORE INSERT OR UPDATE ON booking.show FOR EACH ROW EXECUTE FUNCTION booking.check_show_overlap();


--
-- Name: booked_seat booked_seat_booking_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booked_seat
    ADD CONSTRAINT booked_seat_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES booking.booking(booking_id);


--
-- Name: booked_seat booked_seat_seat_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booked_seat
    ADD CONSTRAINT booked_seat_seat_id_fkey FOREIGN KEY (seat_id) REFERENCES booking.seat(seat_id);


--
-- Name: booked_seat booked_seat_show_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booked_seat
    ADD CONSTRAINT booked_seat_show_id_fkey FOREIGN KEY (show_id) REFERENCES booking.show(show_id);


--
-- Name: booking booking_show_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booking
    ADD CONSTRAINT booking_show_id_fkey FOREIGN KEY (show_id) REFERENCES booking.show(show_id);


-- Name: booking booking_user_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.booking
    ADD CONSTRAINT booking_user_id_fkey FOREIGN KEY (user_id) REFERENCES booking.users(user_id);


--
-- Name: movie_genre movie_genre_genre_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie_genre
    ADD CONSTRAINT movie_genre_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES booking.genre(genre_id);


--
-- Name: movie_genre movie_genre_movie_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie_genre
    ADD CONSTRAINT movie_genre_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES booking.movie(movie_id);


--
-- Name: movie_person movie_person_movie_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie_person
    ADD CONSTRAINT movie_person_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES booking.movie(movie_id);


--
-- Name: movie_person movie_person_person_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.movie_person
    ADD CONSTRAINT movie_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES booking.person(person_id);


--
-- Name: payment payment_booking_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.payment
    ADD CONSTRAINT payment_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES booking.booking(booking_id);


--
-- Name: payment payment_payment_method_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.payment
    ADD CONSTRAINT payment_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES booking.payment_method(payment_method_id);


--
-- Name: review review_movie_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.review
    ADD CONSTRAINT review_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES booking.movie(movie_id);


--
-- Name: review review_user_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.review
    ADD CONSTRAINT review_user_id_fkey FOREIGN KEY (user_id) REFERENCES booking.users(user_id);


--
-- Name: screen screen_theatre_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.screen
    ADD CONSTRAINT screen_theatre_id_fkey FOREIGN KEY (theatre_id) REFERENCES booking.theatre(theatre_id);


--
-- Name: seat seat_screen_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat
    ADD CONSTRAINT seat_screen_id_fkey FOREIGN KEY (screen_id) REFERENCES booking.screen(screen_id);


--
-- Name: seat seat_seat_category_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.seat
    ADD CONSTRAINT seat_seat_category_id_fkey FOREIGN KEY (seat_category_id) REFERENCES booking.seat_category(seat_category_id);


--
-- Name: show show_movie_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show
    ADD CONSTRAINT show_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES booking.movie(movie_id);


--
-- Name: show show_screen_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show
    ADD CONSTRAINT show_screen_id_fkey FOREIGN KEY (screen_id) REFERENCES booking.screen(screen_id);


--
-- Name: show_seat_pricing show_seat_pricing_seat_category_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show_seat_pricing
    ADD CONSTRAINT show_seat_pricing_seat_category_id_fkey FOREIGN KEY (seat_category_id) REFERENCES booking.seat_category(seat_category_id);


--
-- Name: show_seat_pricing show_seat_pricing_show_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.show_seat_pricing
    ADD CONSTRAINT show_seat_pricing_show_id_fkey FOREIGN KEY (show_id) REFERENCES booking.show(show_id);


--
-- Name: theatre theatre_city_id_fkey; Type: FK CONSTRAINT; Schema: booking; Owner: postgres
--

ALTER TABLE ONLY booking.theatre
    ADD CONSTRAINT theatre_city_id_fkey FOREIGN KEY (city_id) REFERENCES booking.city(city_id);


--
-- PostgreSQL database dump complete
--

\unrestrict J2O1WDT58CE4oGDF3mPxyFLK5IdWN88ejMEWbY3ddY09NEDjrlzS2uzpiZaFXXM

