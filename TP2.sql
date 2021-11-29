/*************************************************
PARTIE 1 CREATION DES TABLES ET INSERTION DES ENREGISTREMENTS 
**************************************************/
ALTER SESSION SET NLS_DATE_FORMAT='yyyy-mm-dd';

DROP TABLE RM_Commentaires;
DROP TABLE RM_Critiques;
DROP TABLE RM_Employes;
DROP TABLE RM_Votes_Films_EnAttente;
DROP TABLE RM_ChangementsEnAttente_Films;
DROP TABLE RM_FilmsFavoris_Membres;
DROP TABLE RM_Votes_MurFilms;
DROP TABLE RM_Messages_MurFilms;
DROP TABLE RM_GenresFilms;
DROP TABLE RM_Films;
DROP TABLE RM_Membres;
DROP TABLE RM_Roles;
DROP TABLE RM_Personnes;
DROP TABLE RM_Genres;
DROP TABLE RM_Pays;
DROP SEQUENCE seq_CritiquesID;
DROP SEQUENCE seq_MembresID;

/*************************************************
 A - CRÉATION DES TABLES
**************************************************/

CREATE TABLE RM_Pays
(
  id	number(7) NOT NULL,
  nom   varchar2(50) NOT NULL,
  CONSTRAINT PK_RM_Pays 
    PRIMARY KEY(id),
  CONSTRAINT CK_RM_Pays_nom
  CHECK (REGEXP_LIKE(nom, '[A-Z]{2}$')) 
);
ALTER TABLE RM_Pays MODIFY nom DEFAULT 'Canada';

CREATE TABLE RM_Genres
(
  id 		number(7) NOT NULL,
  nom	 	varchar2(40) NOT NULL,
  CONSTRAINT PK_RM_Genres 
    PRIMARY KEY( id)
);

CREATE TABLE RM_Roles
(
  id 		number(7) NOT NULL,
  nom	 	varchar2(40) NOT NULL,
  CONSTRAINT PK_RM_Roles 
    PRIMARY KEY( id)
);

CREATE TABLE RM_Personnes
(
  id 			number(7) NOT NULL,
  prenom        varchar2(50) NOT NULL,
  nom           varchar2(50) NOT NULL,
  dateNaissance	date NOT NULL,
  sexe			char(1) NOT NULL,
  CONSTRAINT PK_RM_Personnes
    PRIMARY KEY(id),
  CONSTRAINT CK_RM_Personnes_sexe 
    CHECK (sexe IN('H', 'F'))
);

CREATE TABLE RM_Membres
(
  id      		number(7) NOT NULL,
  login    		varchar(50) NOT NULL,
  motPasse    	varchar2(100) NOT NULL,
  email         varchar2(100),
  prenom        varchar2(50) NOT NULL,
  nom           varchar2(50) NOT NULL,
  idPays      	number(7) NOT NULL,
  dateNaissance	date NOT NULL,
  sexe			char(1) NOT NULL,
  siteWeb		varchar2(200)
);

--- Ajout des contraintes dans la table RM_Membres à l'aide de la commande ALTER
ALTER TABLE RM_Membres ADD
    CONSTRAINT PK_Membres_id
    PRIMARY KEY(id);

ALTER TABLE RM_Membres ADD
    CONSTRAINT FK_RM_Membres_Pays_id 
    FOREIGN KEY (idPays)REFERENCES RM_Pays (id);

ALTER TABLE RM_Membres ADD
    CONSTRAINT CK_RM_Membres_sexe 
    CHECK (sexe IN('H', 'F'));
    
ALTER TABLE RM_Membres ADD
    CONSTRAINT CK_IRM_Membres_email 
    CHECK (REGEXP_LIKE(email,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'));

    
ALTER TABLE RM_Membres ADD
    CONSTRAINT CK_RM_Membres_SiteWeb 
    CHECK (REGEXP_LIKE(siteWeb,
    '(http(s)*:\/\/)[a-z0-9.-]{5,256}\.[a-z]{2,6}+$'));
    
    


CREATE TABLE RM_Films
(
  id        		number(7) NOT NULL,
  titre             varchar2(100) NOT NULL,
  dateParution      date NOT NULL,
  description       varchar2(500) ,
  synopsis			varchar2(2000) NOT NULL,
  budget			number(10,2) ,
  profits			number(11,2) ,
  pointage			number(2) ,
  dateModification	date ,
  splashImage		varchar2(50) NOT NULL,
  nbVisitesPage		number(6),
  CONSTRAINT PK_RM_Films 
    PRIMARY KEY(id),
  CONSTRAINT CK_RM_Films_pointage 
    CHECK (pointage BETWEEN 0 AND 10),
  CONSTRAINT CK_RM_Films_date
    CHECK (dateModification >= dateParution),
  CONSTRAINT CK_RM_Films_budget
    CHECK (budget >= 0),
  CONSTRAINT CK_RM_Films_profits
    CHECK (profits >= 0)
);

 -- Ajout du champ Langue dans la table RM_Films a l'aide de la commande ALTER
ALTER TABLE RM_Films ADD 
    LangueOriginale VARCHAR2(2) DEFAULT ('FR') ADD 
    CONSTRAINT CK_RM_Films_LangueOriginale 
    CHECK (REGEXP_LIKE(LangueOriginale, '[A-Z]{2}$'));

CREATE TABLE RM_GenresFilms
(
  idFilm 		number(7) NOT NULL,
  idGenre	 	number(7) NOT NULL,
  CONSTRAINT PK_idFilm_idGenre 
    PRIMARY KEY(idFilm, idGenre),
  CONSTRAINT FK_RM_Films_idFilm 
    FOREIGN KEY (idFilm)REFERENCES RM_Films(id),
  CONSTRAINT FK_RM_Genres_idGenre 
    FOREIGN KEY (idGenre)REFERENCES RM_Genres(id) 
);

CREATE TABLE RM_Messages_MurFilms
(
  id 			number(7) NOT NULL,
  idMembre 		number(7) NOT NULL,
  idFilm       	number(7) NOT NULL,
  message	    varchar2(500),
  dateAjout     date DEFAULT SYSDATE  NOT NULL,
  CONSTRAINT PK_RM_Messages_MurFilms 
    PRIMARY KEY(id),
  CONSTRAINT FK_Membres_idMembre 
    FOREIGN KEY (idMembre)REFERENCES RM_Membres(id),
  CONSTRAINT FK_Films_idFilm 
    FOREIGN KEY (idFilm)REFERENCES RM_Films(id)
);

CREATE TABLE RM_Votes_MurFilms
(
  idMembre 		number(7) NOT NULL,
  idMessage 	number(7) NOT NULL,
  pourContre	char(1) NOT NULL,
  CONSTRAINT PK_idMembre_idMessage 
    PRIMARY KEY(idMembre, idMessage), 
  CONSTRAINT FK_RM_Membres_idMembre 
    FOREIGN KEY (idMembre)REFERENCES RM_Membres(id),
  CONSTRAINT FK_MurFilms_idMessage 
    FOREIGN KEY (idMessage)REFERENCES RM_Messages_MurFilms(id),
  CONSTRAINT CK_MurFilms_pourContre 
    CHECK (pourContre IN('0', '1'))
);

CREATE TABLE RM_FilmsFavoris_Membres
(
  idMembre 		number(7) NOT NULL,
  idFilm	 	number(7) NOT NULL,
  CONSTRAINT PK_Membres_idMembre_idFilm 
    PRIMARY KEY(idMembre, idFilm), 
  CONSTRAINT FK_Membres_RM_Membres_idMembre 
    FOREIGN KEY (idMembre)REFERENCES RM_Membres(id),
  CONSTRAINT FK_Membres_RM_Films_idFilm 
    FOREIGN KEY (idFilm)REFERENCES RM_Films(id)
);

CREATE TABLE RM_ChangementsEnAttente_Films
(
  id        			number(7) NOT NULL,
  idFilm       			number(7) NOT NULL,
  titre             	varchar2(100) NOT NULL,
  dateParution      	date NOT NULL,
  description       	varchar2(500),
  synopsis				varchar2(2000) NOT NULL,
  budget				number(10,2),
  profits				number(11,2),
  pointage				number(2) NOT NULL,
  splashImage			varchar2(50) NOT NULL,
  dateAjout				date DEFAULT SYSDATE  NOT NULL,
  idMembreModification	number(7) NOT NULL,
  actif					char(1) NOT NULL,
  CONSTRAINT PK_ChangementsEnAttente_Films 
    PRIMARY KEY(id),
  CONSTRAINT FK_Films_idFilm_id 
    FOREIGN KEY (idFilm)REFERENCES RM_Films(id),
  CONSTRAINT FK_idMembreModification_id 
    FOREIGN KEY (idMembreModification)REFERENCES RM_Membres(id),
  CONSTRAINT CK_Films_pointage_id 
    CHECK (pointage BETWEEN 0 AND 10),
  CONSTRAINT CK_Films_budget_id
    CHECK (budget >= 0),
  CONSTRAINT CK_Films_profits_id
    CHECK (profits >= 0),
  CONSTRAINT CK_Films_actif_id 
    CHECK (actif IN('0', '1'))
);

CREATE TABLE RM_Votes_Films_EnAttente
(
  idMembre 		number(7) NOT NULL,
  idAttente 	number(7) NOT NULL,
  pourContre	char(1) NOT NULL,
  CONSTRAINT PK_idMembre_idAttente 
    PRIMARY KEY(idMembre, idAttente), 
  CONSTRAINT FK_EnAttente_idMembre 
    FOREIGN KEY (idMembre)REFERENCES RM_Membres(id),
  CONSTRAINT FK_EnAttente_idAttente 
    FOREIGN KEY (idAttente)REFERENCES RM_ChangementsEnAttente_Films(id),
  CONSTRAINT CK_Votes_EnAttente_pourContre 
    CHECK (pourContre IN('0', '1'))
);

CREATE TABLE RM_Employes
(
  idRole 		number(7) NOT NULL,
  idPersonne 	number(7) NOT NULL,
  idFilm	 	number(7) NOT NULL,
  CONSTRAINT PK_idPersonne_idFilm 
    PRIMARY KEY(idRole,idPersonne,idFilm),
  CONSTRAINT FK_Roles_idRole 
    FOREIGN KEY (idRole)REFERENCES RM_Roles(id),
  CONSTRAINT FK_Personnes_idPersonne 
    FOREIGN KEY (idPersonne)REFERENCES RM_Personnes(id),
  CONSTRAINT FK_RM_Employes_RM_Films_idFilm 
    FOREIGN KEY (idFilm)REFERENCES RM_Films(id) 
);

CREATE TABLE RM_Critiques
(
  id                            number(7) NOT NULL,
  pointageGlobal                number(2)  AS((pointageScenario + pointageDistribution + pointageSFX)/3),
  pointageScenario              number(2) NOT NULL,
  pointageDistribution          number(2) NOT NULL,
  pointageSFX                   number(2) NOT NULL,
  commentaires                  varchar2(500)NOT NULL,
  dateAjout                     date DEFAULT SYSDATE NOT NULL,
  idMembre                      number(7) NOT NULL,
  idFilm                        number(7) NOT NULL,
  CONSTRAINT PK_RM_Critiques_id 
    PRIMARY KEY(id),
  CONSTRAINT FK_Membres_idMembre_id 
    FOREIGN KEY (idMembre)REFERENCES RM_Membres(id),
  CONSTRAINT FK_RM_Critiques_Films_idFilm 
    FOREIGN KEY (idFilm)REFERENCES RM_Films(id),
  CONSTRAINT CK_pointageGlobal 
    CHECK (pointageGlobal BETWEEN 0 AND 10),
  CONSTRAINT CK_pointageScenario 
    CHECK (pointageScenario BETWEEN 0 AND 10),
  CONSTRAINT CK_pointageDistribution 
    CHECK (pointageDistribution BETWEEN 0 AND 10),
  CONSTRAINT CK_pointageSFX 
    CHECK (pointageSFX BETWEEN 0 AND 10)
);

CREATE TABLE RM_Commentaires
(
  id                 number(7) NOT NULL,
  idFilm       	     number(7) NOT NULL,
  Commentaire        varchar2(250) NOT NULL,
  DateCommentaire    date NOT NUll,
  CONSTRAINT PK_CommentaireID 
    PRIMARY KEY(id)
);

-- 3.a Commentaires qui serviront au dictionnaire de données sur toutes les tables
COMMENT ON TABLE RM_Pays IS 'Cette table contient le nom des différents pays ' ;
COMMENT ON TABLE RM_Votes_Films_EnAttente IS 'Indique les identifiants des membres ainsi des personnes en attente et un champs de vote';
COMMENT ON TABLE RM_Votes_MurFilms  IS 'Indique les identifiants des membres ainsi les identifiants des messages et un champs de vote';
COMMENT ON TABLE RM_FilmsFavoris_Membres IS 'Contient des identifiants des membres et des films';
COMMENT ON TABLE RM_Films IS 'Expose des informations détaillées sur des films';
COMMENT ON TABLE RM_GenresFilms IS 'Contient des identifiants de films et des identifiants du genre de films' ;
COMMENT ON TABLE RM_Genres IS 'Enumere les genres de films' ;
COMMENT ON TABLE RM_Roles IS 'Enumère le role des acteurs de film';
COMMENT ON TABLE RM_ChangementsEnAttente_Films IS 'Donne des informations sur des changements de films en attente';
COMMENT ON TABLE RM_Membres IS 'Donne des infos personnelles sur chaque membre';
COMMENT ON TABLE RM_Messages_MurFilms IS ' Renseigne sur des differents types de message pour chaque film';
COMMENT ON TABLE RM_Personnes IS 'Donne les renseignements sur des personnes';
COMMENT ON TABLE RM_Employes IS 'Liste des identifiants des tables role, personne et film';
COMMENT ON TABLE RM_Critiques IS 'Contient des champs pouvant servir de calcul ainsi que des commentaires';

-- 3.b Commentaires qui serviront au dictionnaire de données sur les champs de la table RM_Films
COMMENT ON COLUMN RM_Films.id IS 'identifiant de la table RM_Films';
COMMENT ON COLUMN RM_Films.titre IS 'Porte le titre du film ';
COMMENT ON COLUMN RM_Films.dateParution IS 'Donne la date de parution du film';
COMMENT ON COLUMN RM_Films.description IS 'Donne la decription sur chaque film';
COMMENT ON COLUMN RM_Films.synopsis IS 'Récit très bref qui constitue un schéma de scénario';
COMMENT ON COLUMN RM_Films.budget IS 'Donne le budget aloué pour un film';
COMMENT ON COLUMN RM_Films.profits IS 'Donne le profit qu''on peut avaoir sur un film';
COMMENT ON COLUMN RM_Films.pointage IS 'Compte le nombre de point qu''un film peut avoir';
COMMENT ON COLUMN RM_Films.dateModification IS 'Indique les differentes date de modification des films';
COMMENT ON COLUMN RM_Films.splashImage IS 'Porte le nom des fichier de films';
COMMENT ON COLUMN RM_Films.nbVisitesPage IS 'Compte le nombre de visiteur sur des pages de films';
COMMENT ON COLUMN RM_Films.LangueOriginale IS 'Langue originale du films';

/*************************************************
  8. CRÉATION DES INDEX SUR DES CHAMPS APPROPRIÉS
**************************************************/
CREATE INDEX IDX_idPersonne ON RM_Employes(idPersonne);
CREATE INDEX IDX_idFilm ON RM_Employes(idFilm);
CREATE INDEX IDX_idMembre ON RM_Critiques(idMembre);


/*************************************************
  7. CRÉATION DES SÉQUENCES POUR LES ID DES TABLES RM_Membres et RM_Critiques
**************************************************/
CREATE SEQUENCE seq_MembresID START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_CritiquesID START WITH 1 INCREMENT BY 1;

/*************************************************
  B - INSERTION DES DONNÉES DANS CHAQUE TABLE
**************************************************/
-- Insertion de données dans la table RM_Pays
INSERT INTO RM_Pays VALUES (1, 'Canada');
INSERT INTO RM_Pays VALUES (2, 'Italie');
INSERT INTO RM_Pays VALUES (3, 'France');
INSERT INTO RM_Pays VALUES (4, 'Espagne');
INSERT INTO RM_Pays VALUES (5, 'Mexique');
INSERT INTO RM_Pays VALUES (6, 'États-Unis');
INSERT INTO RM_Pays VALUES (7, 'CA');
INSERT INTO RM_Pays VALUES (8, 'FR');

-- Insertion de données dans la table RM_Genres
INSERT INTO RM_Genres VALUES (1, 'Comédie');
INSERT INTO RM_Genres VALUES (2, 'Drame');
INSERT INTO RM_Genres VALUES (3, 'Horreur');
INSERT INTO RM_Genres VALUES (4, 'Musical');
INSERT INTO RM_Genres VALUES (5, 'Comédie');
INSERT INTO RM_Genres VALUES (6, 'Horreur');


-- Insertion de données dans la table RM_Personnes
INSERT INTO RM_Personnes VALUES (1, 'Olivia', 'Colman', '1974-01-30', 'F');
INSERT INTO RM_Personnes VALUES (2, 'Anthony', 'Hopkins', '1937-12-31', 'H');
INSERT INTO RM_Personnes VALUES (3, 'Ryan', 'Gosling', '1980-11-12', 'H');
INSERT INTO RM_Personnes VALUES (4, 'Damien', 'Chazelle', '1985-01-19', 'H');
INSERT INTO RM_Personnes VALUES (5, 'Abdessalem', 'Fessi', '1977-11-16', 'H');
INSERT INTO RM_Personnes VALUES (6, 'Fahd', 'Zahar', '1980-10-08', 'H');


-- Insertion de données dans la table RM_Roles
INSERT INTO RM_Roles VALUES (1, 'Acteur');
INSERT INTO RM_Roles VALUES (2, 'Directeur');
INSERT INTO RM_Roles VALUES (3, 'Musicien');
INSERT INTO RM_Roles VALUES (4, 'Scénariste');
INSERT INTO RM_Roles VALUES (5, 'Figurant');
INSERT INTO RM_Roles VALUES (6, 'Maquilleur');
INSERT INTO RM_Roles VALUES (7, 'Caméraman');
INSERT INTO RM_Roles VALUES (8, 'Musicien');

-- Insertion de données dans la table RM_Membres
INSERT INTO RM_Membres(id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'membreVIP','passw0rd', 'membrevip123@gmail.com', 'Antoine Joseph', 'Dufour Piquet', 3, '1952-2-23', 'H', 'http://domain.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays,dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'groupeabc','famille', 'groupeabc@hotmail.com', 'MARTIN', 'Tchunte', 4, '1992-02-23', 'H', 'https://google.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'president','president', 'president@hotmail.com', 'Sankara', 'Thomas', 6, '1952-02-23', 'H', 'http://president.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'popularite','feminine', 'frontpopulaire@gmail.com', 'Fortin Duschesnau', 'Karine Lafleur', 5, '2004-08-3', 'F', 'https://pupulairary.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'Membre','Honneur', 'frontpopulaire@gmail.com', 'Fortin Duschesnau', 'Karine Lafleur', 7, '2010-08-3', 'F', 'https://pupulairary.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'GodLove','Message', 'message@gmail.com', 'Fortin Duschesnau', 'Karine Lafleur', 8, '2010-08-3', 'F', 'https://pupulairary.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'Victoire','Message', 'viata@gmail.com', 'Duschesnau', 'Girafe', 8, '2010-08-3', 'F', 'https://pupulairary.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'Jaguare','lion', 'poater@gmail.com', 'Levesque', 'Mark', 8, '2010-08-3', 'F', 'https://pupulairary.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'Chiraque','lion', 'piater@gmail.com', 'Pilion', 'Mark', 3, '2010-08-3', 'F', 'https://pupulairary.com');
INSERT INTO RM_Membres (id, login, motPasse, email, prenom, nom, idPays, dateNaissance, sexe, siteWeb) VALUES (seq_MembresID.NEXTVAL,'Chiraquea','liona', 'piatera@gmail.com', 'Pialion', 'Maark', 6, '2010-08-3', 'F', 'https://pupsu.com');


-- Insertion de données dans la table RM_Films
INSERT INTO RM_Films VALUES (20, 'Autant je me suis plainte d''avoir les deux noms toute ma vie, maintenant ma fille.', '2020-03-19', 'A man refuses all assistance from his daughter as he ages. As he tries to make sense of his changing circumstances, he begins to doubt his loved ones, his own mind and even the fabric of his reality.', 'While navigating their careers in Los Angeles, a pianist and an actress fall in love while attempting to reconcile their aspirations for the future. Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes', 250000, 50000, 7, '2021-06-03', 'A man refuses all assistance from his daughter', 500, 'FR' );
INSERT INTO RM_Films  VALUES (2, 'La La Land', '2016-12-25', 'While navigating their careers in Los Angeles, a pianist and an actress fall in love while attempting to reconcile their aspirations for the future.', 'Un vagabond s’éprend d’une belle et jeune vendeuse de fleurs aveugle qui vit avec sa mère, couverte de dettes', 150425, 15090, 8, '2018-06-24','La Vie est belle', 450, 'FR');
INSERT INTO RM_Films  VALUES (25, 'Parole de femme', '2019-2-25', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25025, 320837, 10,'2020-09-10', 'A man refuses all assistance from his daughter', 808, 'AN');
INSERT INTO RM_Films  VALUES (28, 'La guerre des tranchées', '2010-2-05', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25025, 327407, 10,'2020-09-10', 'A man refuses all assistance from his daughter', 908, 'EP');
INSERT INTO RM_Films  VALUES (4, 'Dragon blue', '2010-2-05', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25005, 792541, 10,'2020-09-10', 'A man refuses all assistance from his daughter',2208, 'IT');
INSERT INTO RM_Films  VALUES (6, 'La route de l''espoir', '2020-4-05', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25005, 377273, 8,'2021-06-10', 'A man refuses all assistance from his daughter',2508, 'AN');
INSERT INTO RM_Films  VALUES (10, 'La guerre des princes', '2020-3-28', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25105, 515173, 10,'2021-06-28', 'A man refuses all assistance from his daughter',2208, 'IT');
INSERT INTO RM_Films  VALUES (13, 'Foudre de tempete', '2020-4-28', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25105, 9236571, 10,'2021-06-28', 'A man refuses all assistance from his daughter',2208, 'FR');

INSERT INTO RM_Films  VALUES (14, 'Foudre ', '2021-10-28', 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.', 'Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante.', 25105, 9236571, 10,'2021-11-01', 'A man refuses all assistance from his daughter',2208, 'FR');

--Insertion de données dans la table BI_Commentaires
INSERT INTO RM_Commentaires VALUES(1,20,'A perdu un film.', '2021-09-05');
INSERT INTO RM_Commentaires VALUES(2,25,'A brisé un film.', '2010-09-14');
INSERT INTO RM_Commentaires VALUES(3,2,'A visioné un film.', '2011-09-14');

-- Insertion de données dans la table RM_FilmsFavoris_Membres
INSERT INTO RM_FilmsFavoris_Membres VALUES(1, 20);
INSERT INTO RM_FilmsFavoris_Membres VALUES(3, 20);
INSERT INTO RM_FilmsFavoris_Membres VALUES(2, 2);

-- Insertion de données dans la table RM_GenresFilms
INSERT INTO RM_GenresFilms VALUES (20,1);
INSERT INTO RM_GenresFilms VALUES (20,2);
INSERT INTO RM_GenresFilms VALUES (2,1);
INSERT INTO RM_GenresFilms VALUES (2,4);
INSERT INTO RM_GenresFilms VALUES (2,5);
INSERT INTO RM_GenresFilms VALUES (25,3);
INSERT INTO RM_GenresFilms VALUES (4,2);
INSERT INTO RM_GenresFilms VALUES (13,4);
INSERT INTO RM_GenresFilms VALUES (20,4);
INSERT INTO RM_GenresFilms VALUES (25,4);
INSERT INTO RM_GenresFilms VALUES (14,4);

-- Insertion de données dans la table RM_Messages_MurFilms
INSERT INTO RM_Messages_MurFilms VALUES (102, 1, 20, 'Après avoir été très populaires pendant plus d''une dizaine d''années, les noms de famille composés disparaissent au Québec. Aujourd''hui, moins de 10 % des parents le choisissent encore', '1987-12-31');
INSERT INTO RM_Messages_MurFilms VALUES (75, 3, 2, 'Au début des années 1980, la loi a permis aux femmes de donner leur nom de famille à leurs enfants', '1927-02-1');
INSERT INTO RM_Messages_MurFilms VALUES (25, 2, 2, 'À la naissance d''Émilie, ses parents ont songé à l''idée de le lui donner leurs deux noms de famille, Paquet et Bossé, puis ont changé d''avis.', '2016-09-15');
INSERT INTO RM_Messages_MurFilms VALUES (3, 4, 25, 'Le nom composé est un reflet de ce principe égalitaire, explique Me Alain Roy, spécialisé en droit de la famille', '2019-10-04');

-- Insertion de données dans la table RM_Votes_MurFilms
INSERT INTO RM_Votes_MurFilms VALUES (4, 102, '1');
INSERT INTO RM_Votes_MurFilms VALUES (4, 25, '0');
INSERT INTO RM_Votes_MurFilms VALUES (2, 102, '1');
INSERT INTO RM_Votes_MurFilms VALUES (3, 3, '0');

-- Insertion de données dans la table RM_ChangementsEnAttente_Films
INSERT INTO RM_ChangementsEnAttente_Films VALUES (5, 20, 'Dragon blanc', '2020-11-23', 'Charlot est ouvrier dans une immense usine. Il resserre quotidiennement des boulons. Mais les machines, le travail à la chaîne le rendent malade, il abandonne son poste et recueille une orpheline','Un vagabond s’éprend d’une belle et jeune vendeuse de fleurs aveugle qui vit avec sa mère, couverte de dettes', 150425, 15000, 8, 'La Vie est belle', '2021-06-24', 4, '1' );
INSERT INTO RM_ChangementsEnAttente_Films VALUES (10, 2, 'Trois petits cochons', '2010-01-03', 'Le décès de son père oblige un homme à reprendre l''entreprise familiale de prêts à la construction, qui permet aux plus déshérités de se loger','Novembre 1919. Deux rescapés des tranchées, l''un dessinateur de génie, l''autre modeste comptable, décident de monter une arnaque aux monuments aux morts. Dans la France des années folles, l''entreprise va se révéler aussi dangereuse que spectaculaire.', 60425, 8520, 6, 'Au Revoir Là-haut', '2015-06-12', 2, '0' );
INSERT INTO RM_ChangementsEnAttente_Films VALUES (7, 25, 'Chasse a l''Homme', '1995-01-23', 'Todd Anderson, un garçon plutôt timide, est envoyé dans la prestigieuse académie de Welton, réputée pour être l''une des plus fermées et austères des États-Unis','Kansas, dans les années 30, Moses Pray, escroc à la petite semaine, assiste à l’enterrement d’une ex-maîtresse et accepte d’emmener sa prétendue fille de 9 ans, Addie, chez une tante. Pendant leur trajet, leurs rapports sont tendus.', 250425, 32000, 10, 'La Barbe à papa', '2000-09-10', 1, '1' );

-- Insertion de données dans la table RM_Votes_Films_EnAttente
INSERT INTO RM_Votes_Films_EnAttente VALUES (1, 5, '1');
INSERT INTO RM_Votes_Films_EnAttente VALUES (3, 10, '1');
INSERT INTO RM_Votes_Films_EnAttente VALUES (3, 7, '0');

-- Insertion de données dans la table RM_Employes
INSERT INTO RM_Employes VALUES (1,2,2);
INSERT INTO RM_Employes VALUES (1,2,25);
INSERT INTO RM_Employes VALUES (1,3,2);
INSERT INTO RM_Employes VALUES (2,4,2);
INSERT INTO RM_Employes VALUES (2,1,2);
INSERT INTO RM_Employes VALUES (5,1,13);

-- Insertion de données dans la table RM_Critiques
INSERT INTO RM_Critiques(id, pointageScenario, pointageDistribution, pointageSFX, commentaires, dateAjout, idMembre, idFilm ) VALUES (seq_CritiquesID.NEXTVAL, 9, 5, 5, 'Dans les forêts reculées du nord-ouest des Etats-Unis, vivant isolé de la société, un père dévoué a consacré sa vie toute entière à faire de ses six jeunes enfants d’extraordinaires adultes.Mais quand le destin frappe sa famille, ils doivent abandonner ce paradis qu’il avait créé pour eux', '2021-02-03', 1, 20);
INSERT INTO RM_Critiques (id, pointageScenario, pointageDistribution, pointageSFX, commentaires, dateAjout, idMembre, idFilm ) VALUES (seq_CritiquesID.NEXTVAL, 7, 8, 6, 'Un Méditerranéen très en verve, désinvolte, charmeur et... fanfaron, fait la connaissance d''un étudiant en droit studieux, timide et complexé.', '1954-12-25', 3, 20);
INSERT INTO RM_Critiques  (id, pointageScenario, pointageDistribution, pointageSFX, commentaires, dateAjout, idMembre, idFilm ) VALUES (seq_CritiquesID.NEXTVAL, 1, 3, 4, 'C''est dans cette université qu''il va faire la rencontre d''un professeur de lettres anglaises plutôt étrange, Mr Keating', '2003-05-06', 4, 25);
INSERT INTO RM_Critiques  (id, pointageScenario, pointageDistribution, pointageSFX, commentaires, dateAjout, idMembre, idFilm ) VALUES (seq_CritiquesID.NEXTVAL, 5, 8, 4, 'C''est dans cette université qu''il va faire la rencontre d''un professeur de lettres anglaises plutôt étrange, Mr Keating', '2021-01-06', 4, 25);

/*************************************************
  PARTIE 2 CREATION DES REQUETES
**************************************************/
-------------1-------------                                 
 select count(RM_Films.id) as "Nombre de films par genre",
             RM_Genres.nom as "Genre du film"
             from RM_Films inner join RM_GenresFilms
             on RM_Films.id=RM_GenresFilms.idFilm
             inner join RM_Genres 
             on RM_GenresFilms.idGenre=RM_Genres.id
             where dateParution>add_months(sysdate, - 3)
             group by RM_Genres.nom ;                              
                               
                               
-----------2----------------
select titre as "Titre du film"  ,count(nbVisitesPage) as "Popularite " from RM_Films inner join RM_GenresFilms
on RM_Films.id=RM_GenresFilms.idFilm
inner join RM_Genres 
on RM_GenresFilms.idFilm=RM_Genres.id
where RM_Genres.nom='Drame'
group by titre,RM_Genres.nom
order by  count(nbVisitesPage) desc;

-----------3---------------
select titre,count(RM_Critiques.id)as "Nombre critique" from RM_Films inner join RM_Critiques on 
                                     RM_Films .id= RM_Critiques.idFilm
                                     where dateAjout> add_months(sysdate, - 6)
                                     group by titre 
                                     having count(RM_Critiques.id)=0;
                                     
----------4---------------
SELECT titre AS "Liste des films" 
FROM RM_Films 
WHERE profits < budget * 3;

----------5--------------- 
CREATE OR REPLACE VIEW liste_film AS SELECT rf.titre
FROM rm_films rf  WHERE (  SELECT  COUNT(*) FROM  rm_messages_murfilms rm WHERE rf.id = rm.id ) >= 10
 group by titre 
 having  count(dateModification)>2;
 
---------6---------------                                      
 select RM_Personnes.nom ,RM_Personnes.prenom,count(RM_Genres.id)as "Nombre de comedies" from RM_Personnes inner join RM_Employes
                                        on RM_Employes.idPersonne=RM_Personnes.id inner join RM_films  on RM_Employes.idFilm=RM_Films.id
                                        inner join RM_GenresFilms on RM_Films.id=RM_GenresFilms.idFilm
                                        inner join RM_Genres on RM_GenresFilms.idGenre=RM_Genres.id
                                        where dateParution>add_months(sysdate, - 12) and  RM_Genres.nom='Comedie'
                                        group by RM_Personnes.nom ,RM_Personnes.prenom 
                                        having count(RM_Genres.id)>2;   
                                        
-----------7-----------
SELECT ROUND((SUM(profits)*0.15), 2)||'$' AS "Total des profits" 
FROM RM_Films INNER JOIN RM_GenresFilms ON RM_GenresFilms.idfilm = RM_Films.id 
              INNER JOIN RM_Genres ON RM_Genres.id = RM_GenresFilms.idGenre
WHERE rm_films.dateparution BETWEEN  SYSDATE - 1 and SYSDATE
GROUP BY RM_Genres.nom;



---------8------------
SELECT * FROM (
            SELECT RM_Films.titre AS Films           
            FROM RM_FilmsFavoris_Membres INNER JOIN RM_Films ON RM_Films.id = RM_FilmsFavoris_Membres.idFilm 
            --WHERE EXTRACT(YEAR FROM dateParution) = EXTRACT(YEAR FROM SYSDATE)
            GROUP BY RM_Films.titre        
)WHERE ROWNUM <= 10;

---------9-----------
SELECT RM_Personnes.prenom AS Acteurs, COUNT(RM_Films.id) AS "Nombre films"
FROM RM_Personnes INNER JOIN RM_Employes ON RM_Employes.idPersonne = RM_Personnes.id
                  INNER JOIN RM_Films ON RM_Films.id = RM_Employes.idFilm
                  INNER JOIN RM_Roles ON RM_Roles.id = RM_Employes.idRole
WHERE RM_Roles.nom = 'Acteur'
GROUP BY RM_Personnes.prenom;

---------10---------
SELECT * FROM(
        SELECT RM_Genres.nom AS "Genre qui a le plus de films"
        FROM RM_Genres INNER JOIN RM_GenresFilms ON RM_GenresFilms.idGenre = RM_Genres.id
                       INNER JOIN RM_Films ON RM_Films.id = RM_GenresFilms.idGenre 
        GROUP BY RM_Genres.nom
        ORDER BY COUNT(RM_Films.id) desc)
WHERE ROWNUM = 1; 

-------11----------
SELECT TO_CHAR(ROUND(COUNT(RM_Membres.id)/SUM(RM_Membres.id), 4)*100) AS Pourcentage
FROM RM_Pays
INNER JOIN RM_Membres ON RM_Membres.idPays = RM_Pays.id 
WHERE RM_Pays.nom = 'CA'
GROUP BY RM_Pays.nom;

------12-----------
SELECT UPPER(LTRIM(SUBSTR(RM_Membres.prenom,1,1))) ||', '|| UPPER(LTRIM(SUBSTR(RM_Membres.nom,1,1))) AS "Nom Membre" 
FROM RM_Membres
INNER JOIN RM_Pays ON RM_Pays.id = RM_Membres.idPays 
WHERE RM_Pays.nom IN('CA', 'FR', 'Belgique') AND email LIKE '__a%';

------13------------ 
 select t.* from RM_Personnes t where exists (select 1  
                                                  from RM_Personnes t1 
                                                  where  t1.dateNaissance = t.dateNaissance and t1.id <> t.id
                                                 );


