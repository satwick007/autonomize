--
-- PostgreSQL database dump
--

\restrict 5YmadztZXiorB9aylAAmEOgufZ4NQ3XdAC0yNGNyOi8Dx5GYfJsUhPRwa5wGZ2M

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-06 05:32:21 IST

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 235 (class 1259 OID 17353)
-- Name: attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attachments (
    id integer NOT NULL,
    task_id integer NOT NULL,
    uploaded_by_id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    file_size_bytes integer NOT NULL,
    content_type character varying(120),
    uploaded_at timestamp without time zone NOT NULL,
    is_deleted boolean NOT NULL
);


ALTER TABLE public.attachments OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17352)
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attachments_id_seq OWNER TO postgres;

--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 234
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- TOC entry 233 (class 1259 OID 17324)
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    task_id integer NOT NULL,
    author_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_deleted boolean NOT NULL
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17323)
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comments_id_seq OWNER TO postgres;

--
-- TOC entry 3957 (class 0 OID 0)
-- Dependencies: 232
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- TOC entry 237 (class 1259 OID 17384)
-- Name: registration_otps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registration_otps (
    id integer NOT NULL,
    full_name character varying(120) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    otp_code character varying(6) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_used boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.registration_otps OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17383)
-- Name: registration_otps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.registration_otps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registration_otps_id_seq OWNER TO postgres;

--
-- TOC entry 3958 (class 0 OID 0)
-- Dependencies: 236
-- Name: registration_otps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.registration_otps_id_seq OWNED BY public.registration_otps.id;


--
-- TOC entry 226 (class 1259 OID 17021)
-- Name: tags_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags_master (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.tags_master OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17020)
-- Name: tags_master_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tags_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_master_id_seq OWNER TO postgres;

--
-- TOC entry 3959 (class 0 OID 0)
-- Dependencies: 225
-- Name: tags_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tags_master_id_seq OWNED BY public.tags_master.id;


--
-- TOC entry 224 (class 1259 OID 17007)
-- Name: task_priorities_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_priorities_master (
    id integer NOT NULL,
    code character varying(32) NOT NULL,
    label character varying(80) NOT NULL,
    sort_order integer NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.task_priorities_master OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17006)
-- Name: task_priorities_master_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_priorities_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_priorities_master_id_seq OWNER TO postgres;

--
-- TOC entry 3960 (class 0 OID 0)
-- Dependencies: 223
-- Name: task_priorities_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_priorities_master_id_seq OWNED BY public.task_priorities_master.id;


--
-- TOC entry 222 (class 1259 OID 16993)
-- Name: task_states_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_states_master (
    id integer NOT NULL,
    code character varying(32) NOT NULL,
    label character varying(80) NOT NULL,
    sort_order integer NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.task_states_master OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16992)
-- Name: task_states_master_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_states_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_states_master_id_seq OWNER TO postgres;

--
-- TOC entry 3961 (class 0 OID 0)
-- Dependencies: 221
-- Name: task_states_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_states_master_id_seq OWNED BY public.task_states_master.id;


--
-- TOC entry 231 (class 1259 OID 17305)
-- Name: task_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tags (
    task_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.task_tags OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17259)
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    title character varying(160) NOT NULL,
    description text NOT NULL,
    state_id integer NOT NULL,
    priority_id integer NOT NULL,
    creator_id integer NOT NULL,
    assigned_to_id integer,
    start_date date,
    end_date date,
    target_date date,
    is_deleted boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17258)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 3962 (class 0 OID 0)
-- Dependencies: 229
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- TOC entry 228 (class 1259 OID 17236)
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    session_token_id character varying(64) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.user_sessions OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17235)
-- Name: user_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_sessions_id_seq OWNER TO postgres;

--
-- TOC entry 3963 (class 0 OID 0)
-- Dependencies: 227
-- Name: user_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_sessions_id_seq OWNED BY public.user_sessions.id;


--
-- TOC entry 220 (class 1259 OID 16880)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name character varying(120) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16879)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 3964 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3721 (class 2604 OID 17356)
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- TOC entry 3720 (class 2604 OID 17327)
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- TOC entry 3722 (class 2604 OID 17387)
-- Name: registration_otps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_otps ALTER COLUMN id SET DEFAULT nextval('public.registration_otps_id_seq'::regclass);


--
-- TOC entry 3717 (class 2604 OID 17024)
-- Name: tags_master id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags_master ALTER COLUMN id SET DEFAULT nextval('public.tags_master_id_seq'::regclass);


--
-- TOC entry 3716 (class 2604 OID 17010)
-- Name: task_priorities_master id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_priorities_master ALTER COLUMN id SET DEFAULT nextval('public.task_priorities_master_id_seq'::regclass);


--
-- TOC entry 3715 (class 2604 OID 16996)
-- Name: task_states_master id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_states_master ALTER COLUMN id SET DEFAULT nextval('public.task_states_master_id_seq'::regclass);


--
-- TOC entry 3719 (class 2604 OID 17262)
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- TOC entry 3718 (class 2604 OID 17239)
-- Name: user_sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions ALTER COLUMN id SET DEFAULT nextval('public.user_sessions_id_seq'::regclass);


--
-- TOC entry 3714 (class 2604 OID 16883)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3948 (class 0 OID 17353)
-- Dependencies: 235
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachments (id, task_id, uploaded_by_id, file_name, file_path, file_size_bytes, content_type, uploaded_at, is_deleted) FROM stdin;
8	17	13	Satwick Manepalli (8)_compressed (1).pdf	/Users/satwickmanepalli/Documents/Task Management System Satwick/uploads/1616b7d07e2f4c5eb685fa660297f624_Satwick Manepalli (8)_compressed (1).pdf	25746	application/pdf	2026-04-06 05:08:06.481859	t
9	17	13	Satwick Manepalli (8)_compressed (2).pdf	/Users/satwickmanepalli/Documents/Task Management System Satwick/uploads/72615b65812444b4a0b3e96d73fd2192_Satwick Manepalli (8)_compressed (2).pdf	25746	application/pdf	2026-04-06 05:08:06.508712	t
10	17	13	Satwick Manepalli (8)_compressed.pdf	/Users/satwickmanepalli/Documents/Task Management System Satwick/uploads/88b3a0d81a544f318c0c070d0babfe56_Satwick Manepalli (8)_compressed.pdf	25746	application/pdf	2026-04-06 05:08:06.534956	t
11	17	13	Satwick Manepalli (8)_compressed.pdf	/Users/satwickmanepalli/Documents/Task Management System Satwick/uploads/380d93d6832a437cb9b0b2852d66bb77_Satwick Manepalli (8)_compressed.pdf	25746	application/pdf	2026-04-06 05:08:33.754414	f
12	17	13	Satwick Manepalli (8)_compressed (2).pdf	/Users/satwickmanepalli/Documents/Task Management System Satwick/uploads/3c02d7f6930740bda3d7333e8682a727_Satwick Manepalli (8)_compressed (2).pdf	25746	application/pdf	2026-04-06 05:08:33.773506	f
\.


--
-- TOC entry 3946 (class 0 OID 17324)
-- Dependencies: 233
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, task_id, author_id, content, created_at, updated_at, is_deleted) FROM stdin;
5	17	13	Hello	2026-04-06 05:07:06.336128	2026-04-06 05:07:06.336158	f
4	17	13	Hey , this is Satwick. Hello?	2026-04-06 05:07:02.299758	2026-04-06 05:07:16.074281	t
\.


--
-- TOC entry 3950 (class 0 OID 17384)
-- Dependencies: 237
-- Data for Name: registration_otps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.registration_otps (id, full_name, email, password_hash, otp_code, expires_at, is_used, created_at, updated_at) FROM stdin;
1	Satwick	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$bI2R0hqD8N57z3lv7b13jg$rbJ2yingTYRT5N/vLV1NWht9VomjATybhVlGNYFH0sE	509574	2026-04-05 20:33:11.354678	t	2026-04-05 20:23:11.35477	2026-04-05 20:29:18.097857
2	Sats	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$VSrFGONcCwGAEOLce08JAQ$2.DcAhX5OCapX4RX7q.0rqjRRxa.CXz4reHcZFBhklU	476654	2026-04-05 20:39:18.119772	t	2026-04-05 20:29:18.11983	2026-04-05 20:30:08.185474
3	Sats	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$xHivlfLeWwsBICTE2FuLUQ$plB2gBnSU9q644UBUTYicpOPvj0/uzH0wsGn4czSDAY	002862	2026-04-05 20:40:08.195664	t	2026-04-05 20:30:08.195762	2026-04-05 20:31:00.184504
4	Sats	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$zpkzRqjVmhOCUKpVihGiVA$8BVsHhFB1.lMiE.4nFZ/irW0ZMxbksZJqqIqN5jmZc8	385910	2026-04-05 20:41:00.203333	t	2026-04-05 20:31:00.203787	2026-04-05 20:31:22.519783
5	Sats	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$JKQUAkDo3VtrLaVUitE6pw$AauN4fcDF6V4JfCqM6nMa2pja4IiQircXYiDL237SOo	840618	2026-04-05 20:41:22.534814	t	2026-04-05 20:31:22.534904	2026-04-05 20:31:41.913116
6	Satwick Manepalli Test	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$WislpLQWIsS4916rdc6ZEw$tELjb/OTSX8O/jhMrlv29ZqbUEC2LDqtQC9ggtAMg28	609744	2026-04-06 02:36:56.719643	t	2026-04-06 02:26:56.72008	2026-04-06 02:27:25.121113
7	Satwick Manepalli Test	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$jTGm1Lp3DgFgrDVmLEUIQQ$Sj2IVOfCRA.6zwPAte/QKEx2Zu2I50XLhcX7e6xR6fU	234616	2026-04-06 02:37:25.139316	t	2026-04-06 02:27:25.139385	2026-04-06 02:27:42.51132
8	Test Autonomize	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$BqA0RogxBkBIidG69/4/5w$ECpiZvAfvtONGEvrJ46MTqGGAsXnmKArsPzDFlKfC78	480461	2026-04-06 03:48:01.445201	t	2026-04-06 03:38:01.445362	2026-04-06 03:38:28.570246
9	Test Autonomize	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$fM8ZQ0iJ8R4DYCxFqFUqBQ$laqPBPx/PXtVa9kCfDLmIaQlEkBypfetZ9nL7rMO4Po	671659	2026-04-06 03:51:42.359112	t	2026-04-06 03:41:42.359829	2026-04-06 03:42:03.825297
10	Task User	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$lBJCyNn7v3dOKcVYK4WQ0g$t4kdpNNdUC0HLim4V9OwQavhieOEWLrSIIJ64j47Dkk	491496	2026-04-06 04:14:32.142852	t	2026-04-06 04:04:32.143764	2026-04-06 04:04:51.837626
11	Autonomize User	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$wDin1HrPOcf4n3OulTIGQA$5YX8kdM9vizART97W4oZ9FMGVueF6fIiMk5BpCXWvoY	735463	2026-04-06 04:48:08.091039	t	2026-04-06 04:38:08.091678	2026-04-06 04:38:31.079075
12	Autonomize User	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$eS.l9L63Vuq913oPwdgbYw$VXJfIuqRjDVDcrXLMQPKRDODIJ5744nQyISgqST0EcQ	282813	2026-04-06 05:12:55.945276	t	2026-04-06 05:02:55.946165	2026-04-06 05:03:13.972102
\.


--
-- TOC entry 3939 (class 0 OID 17021)
-- Dependencies: 226
-- Data for Name: tags_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags_master (id, name, is_active) FROM stdin;
1	backend	t
2	frontend	t
3	bug	t
4	urgent	t
5	design	t
6	api	t
7	ux	t
14	auth	t
15	analytics	t
16	review	t
17	database	t
18	ui	t
19	reporting	t
20	upload	t
21	comments	t
22	dashboard	t
38	profile	t
39	filters	t
40	board	t
41	testing	t
\.


--
-- TOC entry 3937 (class 0 OID 17007)
-- Dependencies: 224
-- Data for Name: task_priorities_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_priorities_master (id, code, label, sort_order, is_active) FROM stdin;
1	low	Low	1	t
2	medium	Medium	2	t
3	high	High	3	t
4	critical	Critical	4	t
\.


--
-- TOC entry 3935 (class 0 OID 16993)
-- Dependencies: 222
-- Data for Name: task_states_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_states_master (id, code, label, sort_order, is_active) FROM stdin;
1	todo	Todo	1	t
2	in_progress	In Progress	2	t
3	review	Review	3	t
4	done	Done	4	t
\.


--
-- TOC entry 3944 (class 0 OID 17305)
-- Dependencies: 231
-- Data for Name: task_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_tags (task_id, tag_id) FROM stdin;
1	2
1	18
10	1
10	4
10	6
100	1
100	4
100	6
101	2
101	18
102	1
102	17
103	6
103	14
104	15
104	19
105	16
105	21
106	1
106	20
107	2
107	22
108	5
108	18
109	3
109	4
11	2
11	18
110	1
110	4
110	6
111	2
111	18
112	1
112	17
113	6
113	14
114	15
114	19
115	16
115	21
116	1
116	20
117	2
117	22
118	5
118	18
119	3
119	4
12	1
12	17
120	1
120	4
120	6
13	6
13	14
14	15
14	19
15	16
15	21
16	1
16	20
17	2
17	22
18	5
18	18
19	3
19	4
2	1
2	17
20	1
20	4
20	6
21	2
21	18
22	1
22	17
23	6
23	14
24	15
24	19
25	16
25	21
26	1
26	20
27	2
27	22
28	5
28	18
29	3
29	4
3	6
3	14
30	1
30	4
30	6
31	2
31	18
32	1
32	17
33	6
33	14
34	15
34	19
35	16
35	21
36	1
36	20
37	2
37	22
38	5
38	18
39	3
39	4
4	15
4	19
40	1
40	4
40	6
41	2
41	18
42	1
42	17
43	6
43	14
44	15
44	19
45	16
45	21
46	1
46	20
47	2
47	22
48	5
48	18
49	3
49	4
5	16
5	21
50	1
50	4
50	6
51	2
51	18
52	1
52	17
53	6
53	14
54	15
54	19
55	16
55	21
56	1
56	20
57	2
57	22
58	5
58	18
59	3
59	4
6	1
6	20
60	1
60	4
60	6
61	2
61	18
62	1
62	17
63	6
63	14
64	15
64	19
65	16
65	21
66	1
66	20
67	2
67	22
68	5
68	18
69	3
69	4
7	2
7	22
70	1
70	4
70	6
71	2
71	18
72	1
72	17
73	6
73	14
74	15
74	19
75	16
75	21
76	1
76	20
77	2
77	22
78	5
78	18
79	3
79	4
8	5
8	18
80	1
80	4
80	6
81	2
81	18
82	1
82	17
83	6
83	14
84	15
84	19
85	16
85	21
86	1
86	20
87	2
87	22
88	5
88	18
89	3
89	4
9	3
9	4
90	1
90	4
90	6
91	2
91	18
92	1
92	17
93	6
93	14
94	15
94	19
95	16
95	21
96	1
96	20
97	2
97	22
98	5
98	18
99	3
99	4
121	2
121	18
122	1
122	6
123	6
123	14
124	15
124	19
125	1
125	17
126	16
126	21
127	20
127	22
128	5
128	18
129	2
129	38
130	39
130	40
131	1
131	2
131	4
132	1
132	3
132	4
133	2
133	18
134	1
134	6
135	6
135	14
136	15
136	19
137	1
137	17
138	16
138	21
139	20
139	22
140	5
140	18
141	2
141	38
142	39
142	40
143	1
143	2
143	4
144	1
144	3
144	4
145	2
145	18
146	1
146	6
147	6
147	14
148	15
148	19
149	1
149	17
150	16
150	21
151	20
151	22
152	5
152	18
153	2
153	38
154	39
154	40
155	1
155	2
155	4
156	1
156	3
156	4
157	2
157	18
158	1
158	6
159	6
159	14
160	15
160	19
161	1
161	17
162	16
162	21
163	20
163	22
164	5
164	18
165	2
165	38
166	39
166	40
167	1
167	2
167	4
168	1
168	3
168	4
169	2
169	18
170	1
170	6
171	6
171	14
172	15
172	19
173	1
173	17
174	16
174	21
175	20
175	22
176	5
176	18
177	2
177	38
178	39
178	40
179	1
179	2
179	4
180	1
180	3
180	4
181	2
181	18
182	1
182	6
183	6
183	14
184	15
184	19
185	1
185	17
186	16
186	21
187	20
187	22
188	5
188	18
189	2
189	38
190	39
190	40
191	1
191	2
191	4
192	1
192	3
192	4
193	2
193	18
194	1
194	6
195	6
195	14
196	15
196	19
197	1
197	17
198	16
198	21
199	20
199	22
200	5
200	18
201	2
201	38
202	39
202	40
203	1
203	2
203	4
204	1
204	3
204	4
205	2
205	18
206	1
206	6
207	6
207	14
208	15
208	19
209	1
209	17
210	16
210	21
211	20
211	22
212	5
212	18
213	2
213	38
214	39
214	40
215	1
215	2
215	4
216	1
216	3
216	4
217	2
217	18
218	1
218	6
219	6
219	14
220	15
220	19
220	41
\.


--
-- TOC entry 3943 (class 0 OID 17259)
-- Dependencies: 230
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, title, description, state_id, priority_id, creator_id, assigned_to_id, start_date, end_date, target_date, is_deleted, created_at, updated_at) FROM stdin;
1	Sample Task 1	Generated task #1 for boards, analytics, comments, uploads, and dashboard testing.	1	3	1	1	2026-04-01	2026-04-04	2026-04-03	f	2026-03-31 06:23:16.886277	2026-03-31 06:23:16.886277
2	Sample Task 2	Generated task #2 for boards, analytics, comments, uploads, and dashboard testing.	2	3	2	2	2026-04-02	2026-04-06	2026-04-05	f	2026-03-31 07:23:16.886277	2026-03-31 07:23:16.886277
3	Sample Task 3	Generated task #3 for boards, analytics, comments, uploads, and dashboard testing.	3	2	3	3	2026-04-03	2026-04-08	2026-04-07	f	2026-03-31 08:23:16.886277	2026-03-31 08:23:16.886277
4	Sample Task 4	Generated task #4 for boards, analytics, comments, uploads, and dashboard testing.	4	1	4	4	2026-04-04	2026-04-10	2026-04-05	f	2026-03-31 09:23:16.886277	2026-03-31 09:23:16.886277
5	Sample Task 5	Generated task #5 for boards, analytics, comments, uploads, and dashboard testing.	1	4	5	5	2026-04-05	2026-04-07	2026-04-07	f	2026-03-31 10:23:16.886277	2026-03-31 10:23:16.886277
6	Sample Task 6	Generated task #6 for boards, analytics, comments, uploads, and dashboard testing.	2	3	6	6	2026-04-06	2026-04-09	2026-04-09	f	2026-03-31 11:23:16.886277	2026-03-31 11:23:16.886277
7	Sample Task 7	Generated task #7 for boards, analytics, comments, uploads, and dashboard testing.	3	3	1	1	2026-04-07	2026-04-11	2026-04-11	f	2026-03-31 12:23:16.886277	2026-03-31 12:23:16.886277
8	Sample Task 8	Generated task #8 for boards, analytics, comments, uploads, and dashboard testing.	4	2	2	2	2026-04-08	2026-04-13	2026-04-09	f	2026-03-31 13:23:16.886277	2026-03-31 13:23:16.886277
9	Sample Task 9	Generated task #9 for boards, analytics, comments, uploads, and dashboard testing.	1	1	3	\N	2026-04-09	2026-04-15	2026-04-11	f	2026-03-31 14:23:16.886277	2026-03-31 14:23:16.886277
10	Sample Task 10	Generated task #10 for boards, analytics, comments, uploads, and dashboard testing.	2	4	4	4	2026-04-10	2026-04-12	2026-04-13	f	2026-03-31 15:23:16.886277	2026-03-31 15:23:16.886277
11	Sample Task 11	Generated task #11 for boards, analytics, comments, uploads, and dashboard testing.	3	3	5	5	2026-04-11	2026-04-14	2026-04-15	f	2026-03-31 16:23:16.886277	2026-03-31 16:23:16.886277
12	Sample Task 12	Generated task #12 for boards, analytics, comments, uploads, and dashboard testing.	4	3	6	6	2026-04-12	2026-04-16	2026-04-13	f	2026-03-31 17:23:16.886277	2026-03-31 17:23:16.886277
13	Sample Task 13	Generated task #13 for boards, analytics, comments, uploads, and dashboard testing.	1	2	1	1	2026-04-13	2026-04-18	2026-04-15	f	2026-03-31 18:23:16.886277	2026-03-31 18:23:16.886277
14	Sample Task 14	Generated task #14 for boards, analytics, comments, uploads, and dashboard testing.	2	1	2	2	2026-04-14	2026-04-20	2026-04-17	f	2026-03-31 19:23:16.886277	2026-03-31 19:23:16.886277
15	Sample Task 15	Generated task #15 for boards, analytics, comments, uploads, and dashboard testing.	3	4	3	3	2026-04-15	2026-04-17	2026-04-19	f	2026-03-31 20:23:16.886277	2026-03-31 20:23:16.886277
16	Sample Task 16	Generated task #16 for boards, analytics, comments, uploads, and dashboard testing.	4	3	4	4	2026-04-16	2026-04-19	2026-04-17	f	2026-03-31 21:23:16.886277	2026-03-31 21:23:16.886277
18	Sample Task 18	Generated task #18 for boards, analytics, comments, uploads, and dashboard testing.	2	2	6	\N	2026-04-18	2026-04-23	2026-04-21	f	2026-03-31 23:23:16.886277	2026-03-31 23:23:16.886277
19	Sample Task 19	Generated task #19 for boards, analytics, comments, uploads, and dashboard testing.	3	1	1	1	2026-04-19	2026-04-25	2026-04-23	f	2026-04-01 00:23:16.886277	2026-04-01 00:23:16.886277
20	Sample Task 20	Generated task #20 for boards, analytics, comments, uploads, and dashboard testing.	4	4	2	2	2026-04-20	2026-04-22	2026-04-21	f	2026-04-01 01:23:16.886277	2026-04-01 01:23:16.886277
21	Sample Task 21	Generated task #21 for boards, analytics, comments, uploads, and dashboard testing.	1	3	3	3	2026-04-01	2026-04-04	2026-04-03	f	2026-04-01 02:23:16.886277	2026-04-01 02:23:16.886277
22	Sample Task 22	Generated task #22 for boards, analytics, comments, uploads, and dashboard testing.	2	3	4	4	2026-04-02	2026-04-06	2026-04-05	f	2026-04-01 03:23:16.886277	2026-04-01 03:23:16.886277
23	Sample Task 23	Generated task #23 for boards, analytics, comments, uploads, and dashboard testing.	3	2	5	5	2026-04-03	2026-04-08	2026-04-07	f	2026-04-01 04:23:16.886277	2026-04-01 04:23:16.886277
24	Sample Task 24	Generated task #24 for boards, analytics, comments, uploads, and dashboard testing.	4	1	6	6	2026-04-04	2026-04-10	2026-04-05	f	2026-04-01 05:23:16.886277	2026-04-01 05:23:16.886277
25	Sample Task 25	Generated task #25 for boards, analytics, comments, uploads, and dashboard testing.	1	4	1	1	2026-04-05	2026-04-07	2026-04-07	f	2026-04-01 06:23:16.886277	2026-04-01 06:23:16.886277
26	Sample Task 26	Generated task #26 for boards, analytics, comments, uploads, and dashboard testing.	2	3	2	2	2026-04-06	2026-04-09	2026-04-09	f	2026-04-01 07:23:16.886277	2026-04-01 07:23:16.886277
27	Sample Task 27	Generated task #27 for boards, analytics, comments, uploads, and dashboard testing.	3	3	3	\N	2026-04-07	2026-04-11	2026-04-11	f	2026-04-01 08:23:16.886277	2026-04-01 08:23:16.886277
28	Sample Task 28	Generated task #28 for boards, analytics, comments, uploads, and dashboard testing.	4	2	4	4	2026-04-08	2026-04-13	2026-04-09	f	2026-04-01 09:23:16.886277	2026-04-01 09:23:16.886277
29	Sample Task 29	Generated task #29 for boards, analytics, comments, uploads, and dashboard testing.	1	1	5	5	2026-04-09	2026-04-15	2026-04-11	f	2026-04-01 10:23:16.886277	2026-04-01 10:23:16.886277
30	Sample Task 30	Generated task #30 for boards, analytics, comments, uploads, and dashboard testing.	2	4	6	6	2026-04-10	2026-04-12	2026-04-13	f	2026-04-01 11:23:16.886277	2026-04-01 11:23:16.886277
31	Sample Task 31	Generated task #31 for boards, analytics, comments, uploads, and dashboard testing.	3	3	1	1	2026-04-11	2026-04-14	2026-04-15	f	2026-04-01 12:23:16.886277	2026-04-01 12:23:16.886277
32	Sample Task 32	Generated task #32 for boards, analytics, comments, uploads, and dashboard testing.	4	3	2	2	2026-04-12	2026-04-16	2026-04-13	f	2026-04-01 13:23:16.886277	2026-04-01 13:23:16.886277
33	Sample Task 33	Generated task #33 for boards, analytics, comments, uploads, and dashboard testing.	1	2	3	3	2026-04-13	2026-04-18	2026-04-15	f	2026-04-01 14:23:16.886277	2026-04-01 14:23:16.886277
34	Sample Task 34	Generated task #34 for boards, analytics, comments, uploads, and dashboard testing.	2	1	4	4	2026-04-14	2026-04-20	2026-04-17	f	2026-04-01 15:23:16.886277	2026-04-01 15:23:16.886277
35	Sample Task 35	Generated task #35 for boards, analytics, comments, uploads, and dashboard testing.	3	4	5	5	2026-04-15	2026-04-17	2026-04-19	f	2026-04-01 16:23:16.886277	2026-04-01 16:23:16.886277
36	Sample Task 36	Generated task #36 for boards, analytics, comments, uploads, and dashboard testing.	4	3	6	\N	2026-04-16	2026-04-19	2026-04-17	f	2026-04-01 17:23:16.886277	2026-04-01 17:23:16.886277
37	Sample Task 37	Generated task #37 for boards, analytics, comments, uploads, and dashboard testing.	1	3	1	1	2026-04-17	2026-04-21	2026-04-19	f	2026-04-01 18:23:16.886277	2026-04-01 18:23:16.886277
38	Sample Task 38	Generated task #38 for boards, analytics, comments, uploads, and dashboard testing.	2	2	2	2	2026-04-18	2026-04-23	2026-04-21	f	2026-04-01 19:23:16.886277	2026-04-01 19:23:16.886277
39	Sample Task 39	Generated task #39 for boards, analytics, comments, uploads, and dashboard testing.	3	1	3	3	2026-04-19	2026-04-25	2026-04-23	f	2026-04-01 20:23:16.886277	2026-04-01 20:23:16.886277
40	Sample Task 40	Generated task #40 for boards, analytics, comments, uploads, and dashboard testing.	4	4	4	4	2026-04-20	2026-04-22	2026-04-21	f	2026-04-01 21:23:16.886277	2026-04-01 21:23:16.886277
41	Sample Task 41	Generated task #41 for boards, analytics, comments, uploads, and dashboard testing.	1	3	5	5	2026-04-01	2026-04-04	2026-04-03	f	2026-04-01 22:23:16.886277	2026-04-01 22:23:16.886277
42	Sample Task 42	Generated task #42 for boards, analytics, comments, uploads, and dashboard testing.	2	3	6	6	2026-04-02	2026-04-06	2026-04-05	f	2026-04-01 23:23:16.886277	2026-04-01 23:23:16.886277
43	Sample Task 43	Generated task #43 for boards, analytics, comments, uploads, and dashboard testing.	3	2	1	1	2026-04-03	2026-04-08	2026-04-07	f	2026-04-02 00:23:16.886277	2026-04-02 00:23:16.886277
44	Sample Task 44	Generated task #44 for boards, analytics, comments, uploads, and dashboard testing.	4	1	2	2	2026-04-04	2026-04-10	2026-04-05	f	2026-04-02 01:23:16.886277	2026-04-02 01:23:16.886277
45	Sample Task 45	Generated task #45 for boards, analytics, comments, uploads, and dashboard testing.	1	4	3	\N	2026-04-05	2026-04-07	2026-04-07	f	2026-04-02 02:23:16.886277	2026-04-02 02:23:16.886277
46	Sample Task 46	Generated task #46 for boards, analytics, comments, uploads, and dashboard testing.	2	3	4	4	2026-04-06	2026-04-09	2026-04-09	f	2026-04-02 03:23:16.886277	2026-04-02 03:23:16.886277
47	Sample Task 47	Generated task #47 for boards, analytics, comments, uploads, and dashboard testing.	3	3	5	5	2026-04-07	2026-04-11	2026-04-11	f	2026-04-02 04:23:16.886277	2026-04-02 04:23:16.886277
48	Sample Task 48	Generated task #48 for boards, analytics, comments, uploads, and dashboard testing.	4	2	6	6	2026-04-08	2026-04-13	2026-04-09	f	2026-04-02 05:23:16.886277	2026-04-02 05:23:16.886277
49	Sample Task 49	Generated task #49 for boards, analytics, comments, uploads, and dashboard testing.	1	1	1	1	2026-04-09	2026-04-15	2026-04-11	f	2026-04-02 06:23:16.886277	2026-04-02 06:23:16.886277
50	Sample Task 50	Generated task #50 for boards, analytics, comments, uploads, and dashboard testing.	2	4	2	2	2026-04-10	2026-04-12	2026-04-13	f	2026-04-02 07:23:16.886277	2026-04-02 07:23:16.886277
51	Sample Task 51	Generated task #51 for boards, analytics, comments, uploads, and dashboard testing.	3	3	3	3	2026-04-11	2026-04-14	2026-04-15	f	2026-04-02 08:23:16.886277	2026-04-02 08:23:16.886277
52	Sample Task 52	Generated task #52 for boards, analytics, comments, uploads, and dashboard testing.	4	3	4	4	2026-04-12	2026-04-16	2026-04-13	f	2026-04-02 09:23:16.886277	2026-04-02 09:23:16.886277
53	Sample Task 53	Generated task #53 for boards, analytics, comments, uploads, and dashboard testing.	1	2	5	5	2026-04-13	2026-04-18	2026-04-15	f	2026-04-02 10:23:16.886277	2026-04-02 10:23:16.886277
54	Sample Task 54	Generated task #54 for boards, analytics, comments, uploads, and dashboard testing.	2	1	6	\N	2026-04-14	2026-04-20	2026-04-17	f	2026-04-02 11:23:16.886277	2026-04-02 11:23:16.886277
55	Sample Task 55	Generated task #55 for boards, analytics, comments, uploads, and dashboard testing.	3	4	1	1	2026-04-15	2026-04-17	2026-04-19	f	2026-04-02 12:23:16.886277	2026-04-02 12:23:16.886277
56	Sample Task 56	Generated task #56 for boards, analytics, comments, uploads, and dashboard testing.	4	3	2	2	2026-04-16	2026-04-19	2026-04-17	f	2026-04-02 13:23:16.886277	2026-04-02 13:23:16.886277
57	Sample Task 57	Generated task #57 for boards, analytics, comments, uploads, and dashboard testing.	1	3	3	3	2026-04-17	2026-04-21	2026-04-19	f	2026-04-02 14:23:16.886277	2026-04-02 14:23:16.886277
58	Sample Task 58	Generated task #58 for boards, analytics, comments, uploads, and dashboard testing.	2	2	4	4	2026-04-18	2026-04-23	2026-04-21	f	2026-04-02 15:23:16.886277	2026-04-02 15:23:16.886277
59	Sample Task 59	Generated task #59 for boards, analytics, comments, uploads, and dashboard testing.	3	1	5	5	2026-04-19	2026-04-25	2026-04-23	f	2026-04-02 16:23:16.886277	2026-04-02 16:23:16.886277
60	Sample Task 60	Generated task #60 for boards, analytics, comments, uploads, and dashboard testing.	4	4	6	6	2026-04-20	2026-04-22	2026-04-21	f	2026-04-02 17:23:16.886277	2026-04-02 17:23:16.886277
61	Sample Task 61	Generated task #61 for boards, analytics, comments, uploads, and dashboard testing.	1	3	1	1	2026-04-01	2026-04-04	2026-04-03	f	2026-04-02 18:23:16.886277	2026-04-02 18:23:16.886277
62	Sample Task 62	Generated task #62 for boards, analytics, comments, uploads, and dashboard testing.	2	3	2	2	2026-04-02	2026-04-06	2026-04-05	f	2026-04-02 19:23:16.886277	2026-04-02 19:23:16.886277
63	Sample Task 63	Generated task #63 for boards, analytics, comments, uploads, and dashboard testing.	3	2	3	\N	2026-04-03	2026-04-08	2026-04-07	f	2026-04-02 20:23:16.886277	2026-04-02 20:23:16.886277
64	Sample Task 64	Generated task #64 for boards, analytics, comments, uploads, and dashboard testing.	4	1	4	4	2026-04-04	2026-04-10	2026-04-05	f	2026-04-02 21:23:16.886277	2026-04-02 21:23:16.886277
65	Sample Task 65	Generated task #65 for boards, analytics, comments, uploads, and dashboard testing.	1	4	5	5	2026-04-05	2026-04-07	2026-04-07	f	2026-04-02 22:23:16.886277	2026-04-02 22:23:16.886277
66	Sample Task 66	Generated task #66 for boards, analytics, comments, uploads, and dashboard testing.	2	3	6	6	2026-04-06	2026-04-09	2026-04-09	f	2026-04-02 23:23:16.886277	2026-04-02 23:23:16.886277
67	Sample Task 67	Generated task #67 for boards, analytics, comments, uploads, and dashboard testing.	3	3	1	1	2026-04-07	2026-04-11	2026-04-11	f	2026-04-03 00:23:16.886277	2026-04-03 00:23:16.886277
68	Sample Task 68	Generated task #68 for boards, analytics, comments, uploads, and dashboard testing.	4	2	2	2	2026-04-08	2026-04-13	2026-04-09	f	2026-04-03 01:23:16.886277	2026-04-03 01:23:16.886277
69	Sample Task 69	Generated task #69 for boards, analytics, comments, uploads, and dashboard testing.	1	1	3	3	2026-04-09	2026-04-15	2026-04-11	f	2026-04-03 02:23:16.886277	2026-04-03 02:23:16.886277
70	Sample Task 70	Generated task #70 for boards, analytics, comments, uploads, and dashboard testing.	2	4	4	4	2026-04-10	2026-04-12	2026-04-13	f	2026-04-03 03:23:16.886277	2026-04-03 03:23:16.886277
71	Sample Task 71	Generated task #71 for boards, analytics, comments, uploads, and dashboard testing.	3	3	5	5	2026-04-11	2026-04-14	2026-04-15	f	2026-04-03 04:23:16.886277	2026-04-03 04:23:16.886277
72	Sample Task 72	Generated task #72 for boards, analytics, comments, uploads, and dashboard testing.	4	3	6	\N	2026-04-12	2026-04-16	2026-04-13	f	2026-04-03 05:23:16.886277	2026-04-03 05:23:16.886277
73	Sample Task 73	Generated task #73 for boards, analytics, comments, uploads, and dashboard testing.	1	2	1	1	2026-04-13	2026-04-18	2026-04-15	f	2026-04-03 06:23:16.886277	2026-04-03 06:23:16.886277
74	Sample Task 74	Generated task #74 for boards, analytics, comments, uploads, and dashboard testing.	2	1	2	2	2026-04-14	2026-04-20	2026-04-17	f	2026-04-03 07:23:16.886277	2026-04-03 07:23:16.886277
75	Sample Task 75	Generated task #75 for boards, analytics, comments, uploads, and dashboard testing.	3	4	3	3	2026-04-15	2026-04-17	2026-04-19	f	2026-04-03 08:23:16.886277	2026-04-03 08:23:16.886277
76	Sample Task 76	Generated task #76 for boards, analytics, comments, uploads, and dashboard testing.	4	3	4	4	2026-04-16	2026-04-19	2026-04-17	f	2026-04-03 09:23:16.886277	2026-04-03 09:23:16.886277
77	Sample Task 77	Generated task #77 for boards, analytics, comments, uploads, and dashboard testing.	1	3	5	5	2026-04-17	2026-04-21	2026-04-19	f	2026-04-03 10:23:16.886277	2026-04-03 10:23:16.886277
78	Sample Task 78	Generated task #78 for boards, analytics, comments, uploads, and dashboard testing.	2	2	6	6	2026-04-18	2026-04-23	2026-04-21	f	2026-04-03 11:23:16.886277	2026-04-03 11:23:16.886277
79	Sample Task 79	Generated task #79 for boards, analytics, comments, uploads, and dashboard testing.	3	1	1	1	2026-04-19	2026-04-25	2026-04-23	f	2026-04-03 12:23:16.886277	2026-04-03 12:23:16.886277
80	Sample Task 80	Generated task #80 for boards, analytics, comments, uploads, and dashboard testing.	4	4	2	2	2026-04-20	2026-04-22	2026-04-21	f	2026-04-03 13:23:16.886277	2026-04-03 13:23:16.886277
81	Sample Task 81	Generated task #81 for boards, analytics, comments, uploads, and dashboard testing.	1	3	3	\N	2026-04-01	2026-04-04	2026-04-03	f	2026-04-03 14:23:16.886277	2026-04-03 14:23:16.886277
82	Sample Task 82	Generated task #82 for boards, analytics, comments, uploads, and dashboard testing.	2	3	4	4	2026-04-02	2026-04-06	2026-04-05	f	2026-04-03 15:23:16.886277	2026-04-03 15:23:16.886277
83	Sample Task 83	Generated task #83 for boards, analytics, comments, uploads, and dashboard testing.	3	2	5	5	2026-04-03	2026-04-08	2026-04-07	f	2026-04-03 16:23:16.886277	2026-04-03 16:23:16.886277
84	Sample Task 84	Generated task #84 for boards, analytics, comments, uploads, and dashboard testing.	4	1	6	6	2026-04-04	2026-04-10	2026-04-05	f	2026-04-03 17:23:16.886277	2026-04-03 17:23:16.886277
85	Sample Task 85	Generated task #85 for boards, analytics, comments, uploads, and dashboard testing.	1	4	1	1	2026-04-05	2026-04-07	2026-04-07	f	2026-04-03 18:23:16.886277	2026-04-03 18:23:16.886277
86	Sample Task 86	Generated task #86 for boards, analytics, comments, uploads, and dashboard testing.	2	3	2	2	2026-04-06	2026-04-09	2026-04-09	f	2026-04-03 19:23:16.886277	2026-04-03 19:23:16.886277
87	Sample Task 87	Generated task #87 for boards, analytics, comments, uploads, and dashboard testing.	3	3	3	3	2026-04-07	2026-04-11	2026-04-11	f	2026-04-03 20:23:16.886277	2026-04-03 20:23:16.886277
88	Sample Task 88	Generated task #88 for boards, analytics, comments, uploads, and dashboard testing.	4	2	4	4	2026-04-08	2026-04-13	2026-04-09	f	2026-04-03 21:23:16.886277	2026-04-03 21:23:16.886277
89	Sample Task 89	Generated task #89 for boards, analytics, comments, uploads, and dashboard testing.	1	1	5	5	2026-04-09	2026-04-15	2026-04-11	f	2026-04-03 22:23:16.886277	2026-04-03 22:23:16.886277
90	Sample Task 90	Generated task #90 for boards, analytics, comments, uploads, and dashboard testing.	2	4	6	\N	2026-04-10	2026-04-12	2026-04-13	f	2026-04-03 23:23:16.886277	2026-04-03 23:23:16.886277
91	Sample Task 91	Generated task #91 for boards, analytics, comments, uploads, and dashboard testing.	3	3	1	1	2026-04-11	2026-04-14	2026-04-15	f	2026-04-04 00:23:16.886277	2026-04-04 00:23:16.886277
92	Sample Task 92	Generated task #92 for boards, analytics, comments, uploads, and dashboard testing.	4	3	2	2	2026-04-12	2026-04-16	2026-04-13	f	2026-04-04 01:23:16.886277	2026-04-04 01:23:16.886277
93	Sample Task 93	Generated task #93 for boards, analytics, comments, uploads, and dashboard testing.	1	2	3	3	2026-04-13	2026-04-18	2026-04-15	f	2026-04-04 02:23:16.886277	2026-04-04 02:23:16.886277
94	Sample Task 94	Generated task #94 for boards, analytics, comments, uploads, and dashboard testing.	2	1	4	4	2026-04-14	2026-04-20	2026-04-17	f	2026-04-04 03:23:16.886277	2026-04-04 03:23:16.886277
95	Sample Task 95	Generated task #95 for boards, analytics, comments, uploads, and dashboard testing.	3	4	5	5	2026-04-15	2026-04-17	2026-04-19	f	2026-04-04 04:23:16.886277	2026-04-04 04:23:16.886277
96	Sample Task 96	Generated task #96 for boards, analytics, comments, uploads, and dashboard testing.	4	3	6	6	2026-04-16	2026-04-19	2026-04-17	f	2026-04-04 05:23:16.886277	2026-04-04 05:23:16.886277
97	Sample Task 97	Generated task #97 for boards, analytics, comments, uploads, and dashboard testing.	1	3	1	1	2026-04-17	2026-04-21	2026-04-19	f	2026-04-04 06:23:16.886277	2026-04-04 06:23:16.886277
98	Sample Task 98	Generated task #98 for boards, analytics, comments, uploads, and dashboard testing.	2	2	2	2	2026-04-18	2026-04-23	2026-04-21	f	2026-04-04 07:23:16.886277	2026-04-04 07:23:16.886277
99	Sample Task 99	Generated task #99 for boards, analytics, comments, uploads, and dashboard testing.	3	1	3	\N	2026-04-19	2026-04-25	2026-04-23	f	2026-04-04 08:23:16.886277	2026-04-04 08:23:16.886277
100	Sample Task 100	Generated task #100 for boards, analytics, comments, uploads, and dashboard testing.	4	4	4	4	2026-04-20	2026-04-22	2026-04-21	f	2026-04-04 09:23:16.886277	2026-04-04 09:23:16.886277
101	Sample Task 101	Generated task #101 for boards, analytics, comments, uploads, and dashboard testing.	1	3	5	5	2026-04-01	2026-04-04	2026-04-03	f	2026-04-04 10:23:16.886277	2026-04-04 10:23:16.886277
102	Sample Task 102	Generated task #102 for boards, analytics, comments, uploads, and dashboard testing.	2	3	6	6	2026-04-02	2026-04-06	2026-04-05	f	2026-04-04 11:23:16.886277	2026-04-04 11:23:16.886277
103	Sample Task 103	Generated task #103 for boards, analytics, comments, uploads, and dashboard testing.	3	2	1	1	2026-04-03	2026-04-08	2026-04-07	f	2026-04-04 12:23:16.886277	2026-04-04 12:23:16.886277
104	Sample Task 104	Generated task #104 for boards, analytics, comments, uploads, and dashboard testing.	4	1	2	2	2026-04-04	2026-04-10	2026-04-05	f	2026-04-04 13:23:16.886277	2026-04-04 13:23:16.886277
105	Sample Task 105	Generated task #105 for boards, analytics, comments, uploads, and dashboard testing.	1	4	3	3	2026-04-05	2026-04-07	2026-04-07	f	2026-04-04 14:23:16.886277	2026-04-04 14:23:16.886277
106	Sample Task 106	Generated task #106 for boards, analytics, comments, uploads, and dashboard testing.	2	3	4	4	2026-04-06	2026-04-09	2026-04-09	f	2026-04-04 15:23:16.886277	2026-04-04 15:23:16.886277
107	Sample Task 107	Generated task #107 for boards, analytics, comments, uploads, and dashboard testing.	3	3	5	5	2026-04-07	2026-04-11	2026-04-11	f	2026-04-04 16:23:16.886277	2026-04-04 16:23:16.886277
108	Sample Task 108	Generated task #108 for boards, analytics, comments, uploads, and dashboard testing.	4	2	6	\N	2026-04-08	2026-04-13	2026-04-09	f	2026-04-04 17:23:16.886277	2026-04-04 17:23:16.886277
109	Sample Task 109	Generated task #109 for boards, analytics, comments, uploads, and dashboard testing.	1	1	1	1	2026-04-09	2026-04-15	2026-04-11	f	2026-04-04 18:23:16.886277	2026-04-04 18:23:16.886277
110	Sample Task 110	Generated task #110 for boards, analytics, comments, uploads, and dashboard testing.	2	4	2	2	2026-04-10	2026-04-12	2026-04-13	f	2026-04-04 19:23:16.886277	2026-04-04 19:23:16.886277
111	Sample Task 111	Generated task #111 for boards, analytics, comments, uploads, and dashboard testing.	3	3	3	3	2026-04-11	2026-04-14	2026-04-15	f	2026-04-04 20:23:16.886277	2026-04-04 20:23:16.886277
112	Sample Task 112	Generated task #112 for boards, analytics, comments, uploads, and dashboard testing.	4	3	4	4	2026-04-12	2026-04-16	2026-04-13	f	2026-04-04 21:23:16.886277	2026-04-04 21:23:16.886277
113	Sample Task 113	Generated task #113 for boards, analytics, comments, uploads, and dashboard testing.	1	2	5	5	2026-04-13	2026-04-18	2026-04-15	f	2026-04-04 22:23:16.886277	2026-04-04 22:23:16.886277
114	Sample Task 114	Generated task #114 for boards, analytics, comments, uploads, and dashboard testing.	2	1	6	6	2026-04-14	2026-04-20	2026-04-17	f	2026-04-04 23:23:16.886277	2026-04-04 23:23:16.886277
115	Sample Task 115	Generated task #115 for boards, analytics, comments, uploads, and dashboard testing.	3	4	1	1	2026-04-15	2026-04-17	2026-04-19	f	2026-04-05 00:23:16.886277	2026-04-05 00:23:16.886277
116	Sample Task 116	Generated task #116 for boards, analytics, comments, uploads, and dashboard testing.	4	3	2	2	2026-04-16	2026-04-19	2026-04-17	f	2026-04-05 01:23:16.886277	2026-04-05 01:23:16.886277
117	Sample Task 117	Generated task #117 for boards, analytics, comments, uploads, and dashboard testing.	1	3	3	\N	2026-04-17	2026-04-21	2026-04-19	f	2026-04-05 02:23:16.886277	2026-04-05 02:23:16.886277
118	Sample Task 118	Generated task #118 for boards, analytics, comments, uploads, and dashboard testing.	2	2	4	4	2026-04-18	2026-04-23	2026-04-21	f	2026-04-05 03:23:16.886277	2026-04-05 03:23:16.886277
119	Sample Task 119	Generated task #119 for boards, analytics, comments, uploads, and dashboard testing.	3	1	5	5	2026-04-19	2026-04-25	2026-04-23	f	2026-04-05 04:23:16.886277	2026-04-05 04:23:16.886277
120	Sample Task 120	Generated task #120 for boards, analytics, comments, uploads, and dashboard testing.	4	4	6	6	2026-04-20	2026-04-22	2026-04-21	f	2026-04-05 05:23:16.886277	2026-04-05 05:23:16.886277
121	Work Item 1	Seeded task #1 with varied states, priorities, assignees, and dates.	1	4	1	3	2026-04-02	2026-04-06	2026-04-05	f	2026-03-28 18:25:24.188951	2026-03-28 18:25:24.188951
122	Work Item 2	Seeded task #2 with varied states, priorities, assignees, and dates.	1	3	2	4	2026-04-03	2026-04-08	2026-04-07	f	2026-03-28 19:25:24.188951	2026-03-28 19:25:24.188951
123	Work Item 3	Seeded task #3 with varied states, priorities, assignees, and dates.	1	3	3	5	2026-04-04	2026-04-10	2026-04-06	f	2026-03-28 20:25:24.188951	2026-03-28 20:25:24.188951
124	Work Item 4	Seeded task #4 with varied states, priorities, assignees, and dates.	1	3	4	6	2026-04-05	2026-04-08	2026-04-08	f	2026-03-28 21:25:24.188951	2026-03-28 21:25:24.188951
125	Work Item 5	Seeded task #5 with varied states, priorities, assignees, and dates.	1	3	5	1	2026-04-06	2026-04-10	2026-04-10	f	2026-03-28 22:25:24.188951	2026-03-28 22:25:24.188951
126	Work Item 6	Seeded task #6 with varied states, priorities, assignees, and dates.	1	3	6	2	2026-04-07	2026-04-12	2026-04-09	f	2026-03-28 23:25:24.188951	2026-03-28 23:25:24.188951
127	Work Item 7	Seeded task #7 with varied states, priorities, assignees, and dates.	1	3	1	3	2026-04-08	2026-04-14	2026-04-11	f	2026-03-29 00:25:24.188951	2026-03-29 00:25:24.188951
128	Work Item 8	Seeded task #8 with varied states, priorities, assignees, and dates.	2	3	2	4	2026-04-09	2026-04-12	2026-04-13	f	2026-03-29 01:25:24.188951	2026-03-29 01:25:24.188951
129	Work Item 9	Seeded task #9 with varied states, priorities, assignees, and dates.	2	2	3	5	2026-04-10	2026-04-14	2026-04-12	f	2026-03-29 02:25:24.188951	2026-03-29 02:25:24.188951
130	Work Item 10	Seeded task #10 with varied states, priorities, assignees, and dates.	2	2	4	6	2026-04-11	2026-04-16	2026-04-14	f	2026-03-29 03:25:24.188951	2026-03-29 03:25:24.188951
131	Work Item 11	Seeded task #11 with varied states, priorities, assignees, and dates.	2	2	5	\N	2026-04-12	2026-04-18	2026-04-16	f	2026-03-29 04:25:24.188951	2026-03-29 04:25:24.188951
132	Work Item 12	Seeded task #12 with varied states, priorities, assignees, and dates.	2	2	6	2	2026-04-13	2026-04-16	2026-04-15	f	2026-03-29 05:25:24.188951	2026-03-29 05:25:24.188951
133	Work Item 13	Seeded task #13 with varied states, priorities, assignees, and dates.	2	2	1	3	2026-04-14	2026-04-18	2026-04-17	f	2026-03-29 06:25:24.188951	2026-03-29 06:25:24.188951
134	Work Item 14	Seeded task #14 with varied states, priorities, assignees, and dates.	3	2	2	4	2026-04-15	2026-04-20	2026-04-19	f	2026-03-29 07:25:24.188951	2026-03-29 07:25:24.188951
135	Work Item 15	Seeded task #15 with varied states, priorities, assignees, and dates.	3	2	3	5	2026-04-16	2026-04-22	2026-04-18	f	2026-03-29 08:25:24.188951	2026-03-29 08:25:24.188951
136	Work Item 16	Seeded task #16 with varied states, priorities, assignees, and dates.	3	1	4	6	2026-04-17	2026-04-20	2026-04-20	f	2026-03-29 09:25:24.188951	2026-03-29 09:25:24.188951
137	Work Item 17	Seeded task #17 with varied states, priorities, assignees, and dates.	4	1	5	1	2026-04-18	2026-04-22	2026-04-22	f	2026-03-29 10:25:24.188951	2026-03-29 10:25:24.188951
138	Work Item 18	Seeded task #18 with varied states, priorities, assignees, and dates.	4	1	6	2	2026-04-01	2026-04-06	2026-04-03	f	2026-03-29 11:25:24.188951	2026-03-29 11:25:24.188951
139	Work Item 19	Seeded task #19 with varied states, priorities, assignees, and dates.	4	1	1	3	2026-04-02	2026-04-08	2026-04-05	f	2026-03-29 12:25:24.188951	2026-03-29 12:25:24.188951
140	Work Item 20	Seeded task #20 with varied states, priorities, assignees, and dates.	1	4	2	4	2026-04-03	2026-04-06	2026-04-07	f	2026-03-29 13:25:24.188951	2026-03-29 13:25:24.188951
141	Work Item 21	Seeded task #21 with varied states, priorities, assignees, and dates.	1	4	3	5	2026-04-04	2026-04-08	2026-04-06	f	2026-03-29 14:25:24.188951	2026-03-29 14:25:24.188951
142	Work Item 22	Seeded task #22 with varied states, priorities, assignees, and dates.	1	3	4	\N	2026-04-05	2026-04-10	2026-04-08	f	2026-03-29 15:25:24.188951	2026-03-29 15:25:24.188951
143	Work Item 23	Seeded task #23 with varied states, priorities, assignees, and dates.	1	3	5	1	2026-04-06	2026-04-12	2026-04-10	f	2026-03-29 16:25:24.188951	2026-03-29 16:25:24.188951
144	Work Item 24	Seeded task #24 with varied states, priorities, assignees, and dates.	1	3	6	2	2026-04-07	2026-04-10	2026-04-09	f	2026-03-29 17:25:24.188951	2026-03-29 17:25:24.188951
145	Work Item 25	Seeded task #25 with varied states, priorities, assignees, and dates.	1	3	1	3	2026-04-08	2026-04-12	2026-04-11	f	2026-03-29 18:25:24.188951	2026-03-29 18:25:24.188951
146	Work Item 26	Seeded task #26 with varied states, priorities, assignees, and dates.	1	3	2	4	2026-04-09	2026-04-14	2026-04-13	f	2026-03-29 19:25:24.188951	2026-03-29 19:25:24.188951
147	Work Item 27	Seeded task #27 with varied states, priorities, assignees, and dates.	1	3	3	5	2026-04-10	2026-04-16	2026-04-12	f	2026-03-29 20:25:24.188951	2026-03-29 20:25:24.188951
148	Work Item 28	Seeded task #28 with varied states, priorities, assignees, and dates.	2	3	4	6	2026-04-11	2026-04-14	2026-04-14	f	2026-03-29 21:25:24.188951	2026-03-29 21:25:24.188951
149	Work Item 29	Seeded task #29 with varied states, priorities, assignees, and dates.	2	2	5	1	2026-04-12	2026-04-16	2026-04-16	f	2026-03-29 22:25:24.188951	2026-03-29 22:25:24.188951
150	Work Item 30	Seeded task #30 with varied states, priorities, assignees, and dates.	2	2	6	2	2026-04-13	2026-04-18	2026-04-15	f	2026-03-29 23:25:24.188951	2026-03-29 23:25:24.188951
151	Work Item 31	Seeded task #31 with varied states, priorities, assignees, and dates.	2	2	1	3	2026-04-14	2026-04-20	2026-04-17	f	2026-03-30 00:25:24.188951	2026-03-30 00:25:24.188951
152	Work Item 32	Seeded task #32 with varied states, priorities, assignees, and dates.	2	2	2	4	2026-04-15	2026-04-18	2026-04-19	f	2026-03-30 01:25:24.188951	2026-03-30 01:25:24.188951
153	Work Item 33	Seeded task #33 with varied states, priorities, assignees, and dates.	2	2	3	\N	2026-04-16	2026-04-20	2026-04-18	f	2026-03-30 02:25:24.188951	2026-03-30 02:25:24.188951
154	Work Item 34	Seeded task #34 with varied states, priorities, assignees, and dates.	3	2	4	6	2026-04-17	2026-04-22	2026-04-20	f	2026-03-30 03:25:24.188951	2026-03-30 03:25:24.188951
155	Work Item 35	Seeded task #35 with varied states, priorities, assignees, and dates.	3	2	5	1	2026-04-18	2026-04-24	2026-04-22	f	2026-03-30 04:25:24.188951	2026-03-30 04:25:24.188951
156	Work Item 36	Seeded task #36 with varied states, priorities, assignees, and dates.	3	1	6	2	2026-04-01	2026-04-04	2026-04-03	f	2026-03-30 05:25:24.188951	2026-03-30 05:25:24.188951
157	Work Item 37	Seeded task #37 with varied states, priorities, assignees, and dates.	4	1	1	3	2026-04-02	2026-04-06	2026-04-05	f	2026-03-30 06:25:24.188951	2026-03-30 06:25:24.188951
158	Work Item 38	Seeded task #38 with varied states, priorities, assignees, and dates.	4	1	2	4	2026-04-03	2026-04-08	2026-04-07	f	2026-03-30 07:25:24.188951	2026-03-30 07:25:24.188951
159	Work Item 39	Seeded task #39 with varied states, priorities, assignees, and dates.	4	1	3	5	2026-04-04	2026-04-10	2026-04-06	f	2026-03-30 08:25:24.188951	2026-03-30 08:25:24.188951
160	Work Item 40	Seeded task #40 with varied states, priorities, assignees, and dates.	1	4	4	6	2026-04-05	2026-04-08	2026-04-08	f	2026-03-30 09:25:24.188951	2026-03-30 09:25:24.188951
161	Work Item 41	Seeded task #41 with varied states, priorities, assignees, and dates.	1	4	5	1	2026-04-06	2026-04-10	2026-04-10	f	2026-03-30 10:25:24.188951	2026-03-30 10:25:24.188951
162	Work Item 42	Seeded task #42 with varied states, priorities, assignees, and dates.	1	3	6	2	2026-04-07	2026-04-12	2026-04-09	f	2026-03-30 11:25:24.188951	2026-03-30 11:25:24.188951
163	Work Item 43	Seeded task #43 with varied states, priorities, assignees, and dates.	1	3	1	3	2026-04-08	2026-04-14	2026-04-11	f	2026-03-30 12:25:24.188951	2026-03-30 12:25:24.188951
164	Work Item 44	Seeded task #44 with varied states, priorities, assignees, and dates.	1	3	2	\N	2026-04-09	2026-04-12	2026-04-13	f	2026-03-30 13:25:24.188951	2026-03-30 13:25:24.188951
165	Work Item 45	Seeded task #45 with varied states, priorities, assignees, and dates.	1	3	3	5	2026-04-10	2026-04-14	2026-04-12	f	2026-03-30 14:25:24.188951	2026-03-30 14:25:24.188951
166	Work Item 46	Seeded task #46 with varied states, priorities, assignees, and dates.	1	3	4	6	2026-04-11	2026-04-16	2026-04-14	f	2026-03-30 15:25:24.188951	2026-03-30 15:25:24.188951
167	Work Item 47	Seeded task #47 with varied states, priorities, assignees, and dates.	1	3	5	1	2026-04-12	2026-04-18	2026-04-16	f	2026-03-30 16:25:24.188951	2026-03-30 16:25:24.188951
168	Work Item 48	Seeded task #48 with varied states, priorities, assignees, and dates.	2	3	6	2	2026-04-13	2026-04-16	2026-04-15	f	2026-03-30 17:25:24.188951	2026-03-30 17:25:24.188951
169	Work Item 49	Seeded task #49 with varied states, priorities, assignees, and dates.	2	2	1	3	2026-04-14	2026-04-18	2026-04-17	f	2026-03-30 18:25:24.188951	2026-03-30 18:25:24.188951
170	Work Item 50	Seeded task #50 with varied states, priorities, assignees, and dates.	2	2	2	4	2026-04-15	2026-04-20	2026-04-19	f	2026-03-30 19:25:24.188951	2026-03-30 19:25:24.188951
171	Work Item 51	Seeded task #51 with varied states, priorities, assignees, and dates.	2	2	3	5	2026-04-16	2026-04-22	2026-04-18	f	2026-03-30 20:25:24.188951	2026-03-30 20:25:24.188951
172	Work Item 52	Seeded task #52 with varied states, priorities, assignees, and dates.	2	2	4	6	2026-04-17	2026-04-20	2026-04-20	f	2026-03-30 21:25:24.188951	2026-03-30 21:25:24.188951
173	Work Item 53	Seeded task #53 with varied states, priorities, assignees, and dates.	2	2	5	1	2026-04-18	2026-04-22	2026-04-22	f	2026-03-30 22:25:24.188951	2026-03-30 22:25:24.188951
174	Work Item 54	Seeded task #54 with varied states, priorities, assignees, and dates.	3	2	6	2	2026-04-01	2026-04-06	2026-04-03	f	2026-03-30 23:25:24.188951	2026-03-30 23:25:24.188951
175	Work Item 55	Seeded task #55 with varied states, priorities, assignees, and dates.	3	2	1	\N	2026-04-02	2026-04-08	2026-04-05	f	2026-03-31 00:25:24.188951	2026-03-31 00:25:24.188951
176	Work Item 56	Seeded task #56 with varied states, priorities, assignees, and dates.	3	1	2	4	2026-04-03	2026-04-06	2026-04-07	f	2026-03-31 01:25:24.188951	2026-03-31 01:25:24.188951
177	Work Item 57	Seeded task #57 with varied states, priorities, assignees, and dates.	4	1	3	5	2026-04-04	2026-04-08	2026-04-06	f	2026-03-31 02:25:24.188951	2026-03-31 02:25:24.188951
178	Work Item 58	Seeded task #58 with varied states, priorities, assignees, and dates.	4	1	4	6	2026-04-05	2026-04-10	2026-04-08	f	2026-03-31 03:25:24.188951	2026-03-31 03:25:24.188951
179	Work Item 59	Seeded task #59 with varied states, priorities, assignees, and dates.	4	1	5	1	2026-04-06	2026-04-12	2026-04-10	f	2026-03-31 04:25:24.188951	2026-03-31 04:25:24.188951
180	Work Item 60	Seeded task #60 with varied states, priorities, assignees, and dates.	1	4	6	2	2026-04-07	2026-04-10	2026-04-09	f	2026-03-31 05:25:24.188951	2026-03-31 05:25:24.188951
181	Work Item 61	Seeded task #61 with varied states, priorities, assignees, and dates.	1	4	1	3	2026-04-08	2026-04-12	2026-04-11	f	2026-03-31 06:25:24.188951	2026-03-31 06:25:24.188951
182	Work Item 62	Seeded task #62 with varied states, priorities, assignees, and dates.	1	3	2	4	2026-04-09	2026-04-14	2026-04-13	f	2026-03-31 07:25:24.188951	2026-03-31 07:25:24.188951
183	Work Item 63	Seeded task #63 with varied states, priorities, assignees, and dates.	1	3	3	5	2026-04-10	2026-04-16	2026-04-12	f	2026-03-31 08:25:24.188951	2026-03-31 08:25:24.188951
184	Work Item 64	Seeded task #64 with varied states, priorities, assignees, and dates.	1	3	4	6	2026-04-11	2026-04-14	2026-04-14	f	2026-03-31 09:25:24.188951	2026-03-31 09:25:24.188951
185	Work Item 65	Seeded task #65 with varied states, priorities, assignees, and dates.	1	3	5	1	2026-04-12	2026-04-16	2026-04-16	f	2026-03-31 10:25:24.188951	2026-03-31 10:25:24.188951
186	Work Item 66	Seeded task #66 with varied states, priorities, assignees, and dates.	1	3	6	\N	2026-04-13	2026-04-18	2026-04-15	f	2026-03-31 11:25:24.188951	2026-03-31 11:25:24.188951
187	Work Item 67	Seeded task #67 with varied states, priorities, assignees, and dates.	1	3	1	3	2026-04-14	2026-04-20	2026-04-17	f	2026-03-31 12:25:24.188951	2026-03-31 12:25:24.188951
188	Work Item 68	Seeded task #68 with varied states, priorities, assignees, and dates.	2	3	2	4	2026-04-15	2026-04-18	2026-04-19	f	2026-03-31 13:25:24.188951	2026-03-31 13:25:24.188951
189	Work Item 69	Seeded task #69 with varied states, priorities, assignees, and dates.	2	2	3	5	2026-04-16	2026-04-20	2026-04-18	f	2026-03-31 14:25:24.188951	2026-03-31 14:25:24.188951
190	Work Item 70	Seeded task #70 with varied states, priorities, assignees, and dates.	2	2	4	6	2026-04-17	2026-04-22	2026-04-20	f	2026-03-31 15:25:24.188951	2026-03-31 15:25:24.188951
191	Work Item 71	Seeded task #71 with varied states, priorities, assignees, and dates.	2	2	5	1	2026-04-18	2026-04-24	2026-04-22	f	2026-03-31 16:25:24.188951	2026-03-31 16:25:24.188951
192	Work Item 72	Seeded task #72 with varied states, priorities, assignees, and dates.	2	2	6	2	2026-04-01	2026-04-04	2026-04-03	f	2026-03-31 17:25:24.188951	2026-03-31 17:25:24.188951
193	Work Item 73	Seeded task #73 with varied states, priorities, assignees, and dates.	2	2	1	3	2026-04-02	2026-04-06	2026-04-05	f	2026-03-31 18:25:24.188951	2026-03-31 18:25:24.188951
194	Work Item 74	Seeded task #74 with varied states, priorities, assignees, and dates.	3	2	2	4	2026-04-03	2026-04-08	2026-04-07	f	2026-03-31 19:25:24.188951	2026-03-31 19:25:24.188951
195	Work Item 75	Seeded task #75 with varied states, priorities, assignees, and dates.	3	2	3	5	2026-04-04	2026-04-10	2026-04-06	f	2026-03-31 20:25:24.188951	2026-03-31 20:25:24.188951
196	Work Item 76	Seeded task #76 with varied states, priorities, assignees, and dates.	3	1	4	6	2026-04-05	2026-04-08	2026-04-08	f	2026-03-31 21:25:24.188951	2026-03-31 21:25:24.188951
197	Work Item 77	Seeded task #77 with varied states, priorities, assignees, and dates.	4	1	5	\N	2026-04-06	2026-04-10	2026-04-10	f	2026-03-31 22:25:24.188951	2026-03-31 22:25:24.188951
198	Work Item 78	Seeded task #78 with varied states, priorities, assignees, and dates.	4	1	6	2	2026-04-07	2026-04-12	2026-04-09	f	2026-03-31 23:25:24.188951	2026-03-31 23:25:24.188951
199	Work Item 79	Seeded task #79 with varied states, priorities, assignees, and dates.	4	1	1	3	2026-04-08	2026-04-14	2026-04-11	f	2026-04-01 00:25:24.188951	2026-04-01 00:25:24.188951
200	Work Item 80	Seeded task #80 with varied states, priorities, assignees, and dates.	1	4	2	4	2026-04-09	2026-04-12	2026-04-13	f	2026-04-01 01:25:24.188951	2026-04-01 01:25:24.188951
201	Work Item 81	Seeded task #81 with varied states, priorities, assignees, and dates.	1	4	3	5	2026-04-10	2026-04-14	2026-04-12	f	2026-04-01 02:25:24.188951	2026-04-01 02:25:24.188951
202	Work Item 82	Seeded task #82 with varied states, priorities, assignees, and dates.	1	3	4	6	2026-04-11	2026-04-16	2026-04-14	f	2026-04-01 03:25:24.188951	2026-04-01 03:25:24.188951
203	Work Item 83	Seeded task #83 with varied states, priorities, assignees, and dates.	1	3	5	1	2026-04-12	2026-04-18	2026-04-16	f	2026-04-01 04:25:24.188951	2026-04-01 04:25:24.188951
204	Work Item 84	Seeded task #84 with varied states, priorities, assignees, and dates.	1	3	6	2	2026-04-13	2026-04-16	2026-04-15	f	2026-04-01 05:25:24.188951	2026-04-01 05:25:24.188951
205	Work Item 85	Seeded task #85 with varied states, priorities, assignees, and dates.	1	3	1	3	2026-04-14	2026-04-18	2026-04-17	f	2026-04-01 06:25:24.188951	2026-04-01 06:25:24.188951
208	Work Item 88	Seeded task #88 with varied states, priorities, assignees, and dates.	2	3	4	\N	2026-04-17	2026-04-20	2026-04-20	f	2026-04-01 09:25:24.188951	2026-04-01 09:25:24.188951
209	Work Item 89	Seeded task #89 with varied states, priorities, assignees, and dates.	2	2	5	1	2026-04-18	2026-04-22	2026-04-22	f	2026-04-01 10:25:24.188951	2026-04-01 10:25:24.188951
210	Work Item 90	Seeded task #90 with varied states, priorities, assignees, and dates.	2	2	6	2	2026-04-01	2026-04-06	2026-04-03	f	2026-04-01 11:25:24.188951	2026-04-01 11:25:24.188951
211	Work Item 91	Seeded task #91 with varied states, priorities, assignees, and dates.	2	2	1	3	2026-04-02	2026-04-08	2026-04-05	f	2026-04-01 12:25:24.188951	2026-04-01 12:25:24.188951
212	Work Item 92	Seeded task #92 with varied states, priorities, assignees, and dates.	2	2	2	4	2026-04-03	2026-04-06	2026-04-07	f	2026-04-01 13:25:24.188951	2026-04-01 13:25:24.188951
214	Work Item 94	Seeded task #94 with varied states, priorities, assignees, and dates.	3	2	4	6	2026-04-05	2026-04-10	2026-04-08	f	2026-04-01 15:25:24.188951	2026-04-01 15:25:24.188951
215	Work Item 95	Seeded task #95 with varied states, priorities, assignees, and dates.	3	2	5	1	2026-04-06	2026-04-12	2026-04-10	f	2026-04-01 16:25:24.188951	2026-04-01 16:25:24.188951
217	Work Item 97	Seeded task #97 with varied states, priorities, assignees, and dates.	4	1	1	3	2026-04-08	2026-04-12	2026-04-11	f	2026-04-01 18:25:24.188951	2026-04-01 18:25:24.188951
218	Work Item 98	Seeded task #98 with varied states, priorities, assignees, and dates.	4	1	2	4	2026-04-09	2026-04-14	2026-04-13	f	2026-04-01 19:25:24.188951	2026-04-01 19:25:24.188951
219	Work Item 99	Seeded task #99 with varied states, priorities, assignees, and dates.	4	1	3	\N	2026-04-10	2026-04-16	2026-04-12	f	2026-04-01 20:25:24.188951	2026-04-01 20:25:24.188951
213	Work Item 93	Seeded task #93 with varied states, priorities, assignees, and dates.	3	2	3	5	2026-04-04	2026-04-08	2026-04-06	f	2026-04-01 14:25:24.188951	2026-04-06 02:39:15.918087
216	Work Item 96	Seeded task #96 with varied states, priorities, assignees, and dates.	3	1	6	2	2026-04-07	2026-04-10	2026-04-09	f	2026-04-01 17:25:24.188951	2026-04-06 03:48:26.835478
220	Work Item 100	Seeded task #100 with varied states, priorities, assignees, and dates.	2	4	4	5	2026-04-11	2026-04-14	2026-04-14	f	2026-04-01 21:25:24.188951	2026-04-06 04:10:32.40933
207	Work Item 87	Seeded task #87 with varied states, priorities, assignees, and dates.	2	3	3	5	2026-04-16	2026-04-22	2026-04-18	f	2026-04-01 08:25:24.188951	2026-04-06 04:10:34.277077
206	Work Item 86	Seeded task #86 with varied states, priorities, assignees, and dates.	3	2	2	5	2026-04-15	2026-04-20	2026-04-19	f	2026-04-01 07:25:24.188951	2026-04-06 04:42:26.684444
17	Sample Task 17	Generated task #17 for boards, analytics, comments, uploads, and dashboard testing.	2	3	5	5	2026-04-17	2026-04-21	2026-04-19	f	2026-03-31 22:23:16.886277	2026-04-06 05:08:33.722052
\.


--
-- TOC entry 3941 (class 0 OID 17236)
-- Dependencies: 228
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sessions (id, user_id, session_token_id, expires_at, is_active, created_at, updated_at) FROM stdin;
16	13	aca549ebb4214ec29949803079332ef8	2026-04-06 13:03:13.972851	t	2026-04-06 05:03:13.972918	2026-04-06 05:03:13.972927
\.


--
-- TOC entry 3933 (class 0 OID 16880)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, email, password_hash, is_active, created_at) FROM stdin;
2	Veer reddy	veer@gmail.com	$pbkdf2-sha256$29000$oXSu1dqbk9Ia43yv1drb.w$cXK/GP.UioQ0xf7qGzTMnYHJy7P/VV4u0s6rpoPo/Tk	t	2026-04-05 16:10:54.092498
4	Sree Vardhani	vardhani@gmail.com	$pbkdf2-sha256$29000$vJdSytk7J2RMKcU4p3SO0Q$O9S7cV83jhtZjvFhnnZ1BdVBkxgwSmKPl4nSA7aRwvM	t	2026-04-05 16:12:17.818808
5	Ranga Raju	raju@gmail.com	$pbkdf2-sha256$29000$JgRACIEwBiCkFOIcgzAGoA$in9WbCDBvVCjK4PliiffzP4Zc6ov3EbK4CrrJouiXd4	t	2026-04-05 16:12:49.607473
6	Vamsi	vamsi@gmail.com	$pbkdf2-sha256$29000$V.odg3AuJeS81xrDOAcgRA$RR7WgfU/t5I71NDcnEBO/up0JLJ5KsZRjZUpklFOegA	t	2026-04-05 16:21:28.754342
3	Sumanth Pogaru	sumanth@gmail.com	$pbkdf2-sha256$29000$gLDWWitlzHmvVcoZA2AMIQ$jDOwurkWCcZ.3SHOnhqfGohZsJ9m4FmhNctUFJNZ4.8	t	2026-04-05 16:11:54.728697
1	Satwick Manepalli	satwickmanepalli@gmail.com	$pbkdf2-sha256$29000$fg9hLGUsxXgvBYCQcs6Z8w$51SD3OHh21NKBqq2mQySpd01jXquhVHWVd441a5hCj4	t	2026-04-05 11:40:13.126361
13	Autonomize User 2	satwickmanepalli7@gmail.com	$pbkdf2-sha256$29000$OmfM2TsHQCjF2Htv7d0bgw$gMiIYvLBgjUQWUlCfEvCPc20zozChdG0LydwlgB5yhY	t	2026-04-06 05:03:13.968405
\.


--
-- TOC entry 3965 (class 0 OID 0)
-- Dependencies: 234
-- Name: attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attachments_id_seq', 12, true);


--
-- TOC entry 3966 (class 0 OID 0)
-- Dependencies: 232
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_id_seq', 5, true);


--
-- TOC entry 3967 (class 0 OID 0)
-- Dependencies: 236
-- Name: registration_otps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.registration_otps_id_seq', 12, true);


--
-- TOC entry 3968 (class 0 OID 0)
-- Dependencies: 225
-- Name: tags_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tags_master_id_seq', 41, true);


--
-- TOC entry 3969 (class 0 OID 0)
-- Dependencies: 223
-- Name: task_priorities_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_priorities_master_id_seq', 4, true);


--
-- TOC entry 3970 (class 0 OID 0)
-- Dependencies: 221
-- Name: task_states_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_states_master_id_seq', 4, true);


--
-- TOC entry 3971 (class 0 OID 0)
-- Dependencies: 229
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 224, true);


--
-- TOC entry 3972 (class 0 OID 0)
-- Dependencies: 227
-- Name: user_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_sessions_id_seq', 16, true);


--
-- TOC entry 3973 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- TOC entry 3764 (class 2606 OID 17368)
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 3759 (class 2606 OID 17338)
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 3773 (class 2606 OID 17400)
-- Name: registration_otps registration_otps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_otps
    ADD CONSTRAINT registration_otps_pkey PRIMARY KEY (id);


--
-- TOC entry 3737 (class 2606 OID 17029)
-- Name: tags_master tags_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags_master
    ADD CONSTRAINT tags_master_pkey PRIMARY KEY (id);


--
-- TOC entry 3733 (class 2606 OID 17017)
-- Name: task_priorities_master task_priorities_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_priorities_master
    ADD CONSTRAINT task_priorities_master_pkey PRIMARY KEY (id);


--
-- TOC entry 3729 (class 2606 OID 17003)
-- Name: task_states_master task_states_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_states_master
    ADD CONSTRAINT task_states_master_pkey PRIMARY KEY (id);


--
-- TOC entry 3757 (class 2606 OID 17311)
-- Name: task_tags task_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tags
    ADD CONSTRAINT task_tags_pkey PRIMARY KEY (task_id, tag_id);


--
-- TOC entry 3754 (class 2606 OID 17275)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 3743 (class 2606 OID 17248)
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 3725 (class 2606 OID 16893)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3765 (class 1259 OID 17380)
-- Name: ix_attachments_is_deleted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attachments_is_deleted ON public.attachments USING btree (is_deleted);


--
-- TOC entry 3766 (class 1259 OID 17381)
-- Name: ix_attachments_task_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attachments_task_active ON public.attachments USING btree (task_id, is_deleted);


--
-- TOC entry 3767 (class 1259 OID 17379)
-- Name: ix_attachments_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attachments_task_id ON public.attachments USING btree (task_id);


--
-- TOC entry 3760 (class 1259 OID 17349)
-- Name: ix_comments_is_deleted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_comments_is_deleted ON public.comments USING btree (is_deleted);


--
-- TOC entry 3761 (class 1259 OID 17350)
-- Name: ix_comments_task_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_comments_task_active ON public.comments USING btree (task_id, is_deleted);


--
-- TOC entry 3762 (class 1259 OID 17351)
-- Name: ix_comments_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_comments_task_id ON public.comments USING btree (task_id);


--
-- TOC entry 3768 (class 1259 OID 17404)
-- Name: ix_registration_otps_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_registration_otps_email ON public.registration_otps USING btree (email);


--
-- TOC entry 3769 (class 1259 OID 17403)
-- Name: ix_registration_otps_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_registration_otps_expires_at ON public.registration_otps USING btree (expires_at);


--
-- TOC entry 3770 (class 1259 OID 17402)
-- Name: ix_registration_otps_is_used; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_registration_otps_is_used ON public.registration_otps USING btree (is_used);


--
-- TOC entry 3771 (class 1259 OID 17401)
-- Name: ix_registration_otps_otp_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_registration_otps_otp_code ON public.registration_otps USING btree (otp_code);


--
-- TOC entry 3734 (class 1259 OID 17030)
-- Name: ix_tags_master_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tags_master_is_active ON public.tags_master USING btree (is_active);


--
-- TOC entry 3735 (class 1259 OID 17031)
-- Name: ix_tags_master_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_tags_master_name ON public.tags_master USING btree (name);


--
-- TOC entry 3730 (class 1259 OID 17018)
-- Name: ix_task_priorities_master_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_task_priorities_master_code ON public.task_priorities_master USING btree (code);


--
-- TOC entry 3731 (class 1259 OID 17019)
-- Name: ix_task_priorities_master_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_task_priorities_master_is_active ON public.task_priorities_master USING btree (is_active);


--
-- TOC entry 3726 (class 1259 OID 17005)
-- Name: ix_task_states_master_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_task_states_master_code ON public.task_states_master USING btree (code);


--
-- TOC entry 3727 (class 1259 OID 17004)
-- Name: ix_task_states_master_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_task_states_master_is_active ON public.task_states_master USING btree (is_active);


--
-- TOC entry 3755 (class 1259 OID 17322)
-- Name: ix_task_tags_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_task_tags_tag_id ON public.task_tags USING btree (tag_id);


--
-- TOC entry 3744 (class 1259 OID 17299)
-- Name: ix_tasks_assigned_to_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_assigned_to_id ON public.tasks USING btree (assigned_to_id);


--
-- TOC entry 3745 (class 1259 OID 17303)
-- Name: ix_tasks_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_created_at ON public.tasks USING btree (created_at);


--
-- TOC entry 3746 (class 1259 OID 17297)
-- Name: ix_tasks_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_creator_id ON public.tasks USING btree (creator_id);


--
-- TOC entry 3747 (class 1259 OID 17302)
-- Name: ix_tasks_is_deleted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_is_deleted ON public.tasks USING btree (is_deleted);


--
-- TOC entry 3748 (class 1259 OID 17298)
-- Name: ix_tasks_priority_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_priority_id ON public.tasks USING btree (priority_id);


--
-- TOC entry 3749 (class 1259 OID 17296)
-- Name: ix_tasks_state_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_state_id ON public.tasks USING btree (state_id);


--
-- TOC entry 3750 (class 1259 OID 17300)
-- Name: ix_tasks_state_priority; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_state_priority ON public.tasks USING btree (state_id, priority_id);


--
-- TOC entry 3751 (class 1259 OID 17301)
-- Name: ix_tasks_target_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_target_date ON public.tasks USING btree (target_date);


--
-- TOC entry 3752 (class 1259 OID 17304)
-- Name: ix_tasks_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tasks_title ON public.tasks USING btree (title);


--
-- TOC entry 3738 (class 1259 OID 17255)
-- Name: ix_user_sessions_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_sessions_expires_at ON public.user_sessions USING btree (expires_at);


--
-- TOC entry 3739 (class 1259 OID 17257)
-- Name: ix_user_sessions_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_sessions_is_active ON public.user_sessions USING btree (is_active);


--
-- TOC entry 3740 (class 1259 OID 17254)
-- Name: ix_user_sessions_session_token_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_user_sessions_session_token_id ON public.user_sessions USING btree (session_token_id);


--
-- TOC entry 3741 (class 1259 OID 17256)
-- Name: ix_user_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_sessions_user_id ON public.user_sessions USING btree (user_id);


--
-- TOC entry 3723 (class 1259 OID 16894)
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- TOC entry 3783 (class 2606 OID 17369)
-- Name: attachments attachments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- TOC entry 3784 (class 2606 OID 17374)
-- Name: attachments attachments_uploaded_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_uploaded_by_id_fkey FOREIGN KEY (uploaded_by_id) REFERENCES public.users(id);


--
-- TOC entry 3781 (class 2606 OID 17344)
-- Name: comments comments_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- TOC entry 3782 (class 2606 OID 17339)
-- Name: comments comments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- TOC entry 3779 (class 2606 OID 17317)
-- Name: task_tags task_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tags
    ADD CONSTRAINT task_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags_master(id);


--
-- TOC entry 3780 (class 2606 OID 17312)
-- Name: task_tags task_tags_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tags
    ADD CONSTRAINT task_tags_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- TOC entry 3775 (class 2606 OID 17291)
-- Name: tasks tasks_assigned_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES public.users(id);


--
-- TOC entry 3776 (class 2606 OID 17286)
-- Name: tasks tasks_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- TOC entry 3777 (class 2606 OID 17281)
-- Name: tasks tasks_priority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_priority_id_fkey FOREIGN KEY (priority_id) REFERENCES public.task_priorities_master(id);


--
-- TOC entry 3778 (class 2606 OID 17276)
-- Name: tasks tasks_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.task_states_master(id);


--
-- TOC entry 3774 (class 2606 OID 17249)
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2026-04-06 05:32:22 IST

--
-- PostgreSQL database dump complete
--

\unrestrict 5YmadztZXiorB9aylAAmEOgufZ4NQ3XdAC0yNGNyOi8Dx5GYfJsUhPRwa5wGZ2M

