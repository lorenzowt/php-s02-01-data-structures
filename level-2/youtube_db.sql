/* ==================
   DATABASE CREATION
   ================== */

CREATE SCHEMA IF NOT EXISTS `youtube` DEFAULT CHARACTER SET utf8mb4;
USE `youtube`;

/* ==================
   TABLE CREATION
   ================== */

CREATE TABLE `users` (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('male','female','nonbinary') NOT NULL,
    country VARCHAR(100),
    zipcode VARCHAR(20)
);

CREATE TABLE `videos` (
    video_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_size INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    duration_seconds INT NOT NULL,
    thumbnail VARCHAR(255) NOT NULL,
    views INT NOT NULL DEFAULT 0,
    likes INT NOT NULL DEFAULT 0,
    dislikes INT NOT NULL DEFAULT 0,
    state ENUM('public','unlisted','private') NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX(user_id),

    CONSTRAINT fk_videos_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);


CREATE TABLE `tags` (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE `video_tags` (
    video_id INT NOT NULL,
    tag_id INT NOT NULL,

    PRIMARY KEY(video_id, tag_id),

    INDEX(tag_id),

    CONSTRAINT fk_video_tags_videos
        FOREIGN KEY(video_id)
        REFERENCES videos(video_id),

    CONSTRAINT fk_video_tags_tags
        FOREIGN KEY(tag_id)
        REFERENCES tags(tag_id)
);

CREATE TABLE `channels` (
    channel_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,

    INDEX(user_id),

    CONSTRAINT fk_channels_users
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);

CREATE TABLE `subscriptions` (
    user_id INT NOT NULL,
    channel_id INT NOT NULL,

    PRIMARY KEY(user_id, channel_id),

    INDEX(channel_id),

    CONSTRAINT fk_subscriptions_users
        FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_subscriptions_channels
        FOREIGN KEY(channel_id)
        REFERENCES channels(channel_id)
);

CREATE TABLE `video_reactions` (
    user_id INT NOT NULL,
    video_id INT NOT NULL,
    type ENUM('like','dislike') NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(user_id, video_id),

    INDEX(video_id),

    CONSTRAINT fk_video_reactions_users
        FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_video_reactions_videos
        FOREIGN KEY(video_id)
        REFERENCES videos(video_id)
);


CREATE TABLE `playlists` (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    state ENUM('public','private') NOT NULL,
    user_id INT NOT NULL,

    INDEX(user_id),

    CONSTRAINT fk_playlists_users
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);

CREATE TABLE `playlist_videos` (
    playlist_id INT NOT NULL,
    video_id INT NOT NULL,

    PRIMARY KEY(playlist_id, video_id),

    INDEX(video_id),

    CONSTRAINT fk_playlist_videos_playlists
        FOREIGN KEY(playlist_id)
        REFERENCES playlists(playlist_id),

    CONSTRAINT fk_playlist_videos_videos
        FOREIGN KEY(video_id)
        REFERENCES videos(video_id)
);

CREATE TABLE `comments` (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    video_id INT NOT NULL,
    user_id INT NOT NULL,
    text TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX(user_id),
    INDEX(video_id),

    CONSTRAINT fk_comments_users
        FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_comments_videos
        FOREIGN KEY(video_id)
        REFERENCES videos(video_id)
);

CREATE TABLE `comment_reactions` (
    user_id INT NOT NULL,
    comment_id INT NOT NULL,
    type ENUM('like','dislike') NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(user_id, comment_id),

    INDEX(comment_id),

    CONSTRAINT fk_comment_reactions_users
        FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_comment_reactions_comments
        FOREIGN KEY(comment_id)
        REFERENCES comments(comment_id)
);

/* ==================
   TEST DATA
   ================== */
INSERT INTO users (email, username, password, dob, gender, country, zipcode) VALUES
('alex@mail.com', 'alexdev', 'hashed_pw_1', '2000-05-12', 'male', 'Spain', '08001'),
('maria@mail.com', 'maria_yt', 'hashed_pw_2', '1998-11-03', 'female', 'Spain', '28001'),
('sam@mail.com', 'samtech', 'hashed_pw_3', '2002-07-19', 'nonbinary', 'USA', '10001');

INSERT INTO videos (title, description, file_size, file_name, duration_seconds, thumbnail, views, likes, dislikes, state, user_id) VALUES
('My First Video', 'Welcome to my channel!', 50000, 'video1.mp4', 120, 'thumb1.jpg', 100, 10, 0, 'public', 1),
('React Tutorial', 'Learn React in 10 minutes', 150000, 'react.mp4', 600, 'thumb2.jpg', 500, 80, 2, 'public', 2),
('Gaming Highlights', 'Best moments from my stream', 300000, 'gaming.mp4', 900, 'thumb3.jpg', 1200, 200, 5, 'public', 3);

INSERT INTO tags (name) VALUES
('tutorial'),
('gaming'),
('education'),
('entertainment');

INSERT INTO video_tags (video_id, tag_id) VALUES
(1, 4),
(2, 1),
(2, 3),
(3, 2),
(3, 4);

INSERT INTO channels (name, description, user_id) VALUES
('Alex Dev Channel', 'Tech content and coding', 1),
('Maria Tutorials', 'Programming tutorials', 2),
('Sam Plays', 'Gaming channel', 3);

INSERT INTO subscriptions (user_id, channel_id) VALUES
(1, 2),
(1, 3),
(2, 1),
(3, 1);

INSERT INTO video_reactions (user_id, video_id, type) VALUES
(1, 2, 'like'),
(2, 1, 'like'),
(3, 1, 'like'),
(3, 2, 'dislike');

INSERT INTO playlists (name, state, user_id) VALUES
('My Favorites', 'public', 1),
('Coding List', 'private', 2);

INSERT INTO playlist_videos (playlist_id, video_id) VALUES
(1, 2),
(1, 3),
(2, 2);

INSERT INTO comments (video_id, user_id, text) VALUES
(1, 2, 'Nice video!'),
(1, 3, 'Great start 🔥'),
(2, 1, 'Very helpful tutorial'),
(3, 2, 'Awesome gameplay!');

INSERT INTO comment_reactions (user_id, comment_id, type) VALUES
(1, 1, 'like'),
(2, 3, 'like'),
(3, 2, 'dislike'),
(1, 4, 'like');

/* ==================
   QUERIES
   ================== */
   
-- Show all videos with uploader info
SELECT 
    v.video_id,
    v.title,
    v.views,
    v.likes,
    u.username AS uploader
FROM videos v
JOIN users u ON v.user_id = u.user_id;

-- Show comments with usernames and video title
SELECT 
    c.comment_id,
    c.text,
    u.username,
    v.title AS video_title
FROM comments c
JOIN users u ON c.user_id = u.user_id
JOIN videos v ON c.video_id = v.video_id
ORDER BY c.created_at DESC;

-- show tags for each video
SELECT 
    v.title,
    t.name AS tag
FROM videos v
JOIN video_tags vt ON v.video_id = vt.video_id
JOIN tags t ON vt.tag_id = t.tag_id
ORDER BY v.video_id;



