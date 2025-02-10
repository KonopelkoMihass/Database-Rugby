DROP DATABASE `rugby_club`;

-- Creates database
CREATE DATABASE rugby_club; 

-- Choose the database
USE rugby_club;


-- Creates Table Coaches
CREATE TABLE Coaches (
    CoachID INT NOT NULL UNIQUE AUTO_INCREMENT,		
    CoachName VARCHAR(60),
    ContactInfo VARCHAR(255),
    CertificationLevel VARCHAR(60),
    Specialization VARCHAR(24),
	PRIMARY KEY (CoachID)					-- Sets Primary Key 
);
ALTER TABLE Coaches AUTO_INCREMENT=2000000; -- Sets it to start from 2xxxxxx for coaches

-- Creates Table Teams
CREATE TABLE Teams (
    TeamID INT NOT NULL UNIQUE AUTO_INCREMENT,	
	CoachID INT,
    TeamName VARCHAR(60),
    AgeGroup VARCHAR(24),
	PRIMARY KEY (TeamID),					
	FOREIGN KEY (CoachID)  REFERENCES Coaches(CoachID)		
);
ALTER TABLE Teams AUTO_INCREMENT=3000000; -- Sets it to start from 3xxxxxx for teams

-- Creates Table Members
CREATE TABLE Members (
    MemberID INT NOT NULL UNIQUE AUTO_INCREMENT,		
    MemberName VARCHAR(60),
    ContactInfo VARCHAR(255),
    DateOfBirth DATE,
    JoinDate DATE,
    MembershipType VARCHAR(24),
    PositionPlayed VARCHAR(24),
    TeamID INT,
    FOREIGN KEY (TeamID)  REFERENCES Teams(TeamID),		
	PRIMARY KEY (MemberID)					
);
ALTER TABLE Members AUTO_INCREMENT=1000000; -- Sets it to start from 1xxxxxx for members


-- Creates Table Matches
CREATE TABLE Matches (
    MatchID INT NOT NULL UNIQUE AUTO_INCREMENT,	
    HomeTeamID INT,
    AwayTeamID INT,
	MatchDate DATE,
    Venue VARCHAR(60),
    Results VARCHAR(24),
	PRIMARY KEY (MatchID),					
	FOREIGN KEY (HomeTeamID)  REFERENCES Teams(TeamID),		
    FOREIGN KEY (AwayTeamID)  REFERENCES Teams(TeamID)
);
ALTER TABLE Matches AUTO_INCREMENT=4000000; -- Sets it to start from 4xxxxxx for matches

-- Creates Table Events
CREATE TABLE Events (
    EventID INT NOT NULL UNIQUE AUTO_INCREMENT,	
    EventName VARCHAR(100),
    EventType VARCHAR(100),
	EventDate DATE,
    Location VARCHAR(100),
	PRIMARY KEY (EventID)
);
ALTER TABLE Events AUTO_INCREMENT=5000000; -- Sets it to start from 5xxxxxx for events


-- Create junction table for members and events
CREATE TABLE MembersEvents (
    MemberID INT,
    EventID INT,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (EventID) REFERENCES Events(EventID),
    PRIMARY KEY (MemberID, EventID)
);

-- Create junction table for coaches and events
CREATE TABLE CoachesEvents (
    CoachID INT,
    EventID INT,
    FOREIGN KEY (CoachID) REFERENCES Coaches(CoachID),
    FOREIGN KEY (EventID) REFERENCES Events(EventID),
    PRIMARY KEY (CoachID, EventID)
);

-- This view shows all players and a coach for a team
CREATE VIEW TeamMembersView AS
SELECT 
	team.TeamName,
    Coach.CoachName,
    member.MemberName, member.PositionPlayed
FROM 
    Teams team
JOIN Members member ON team.TeamID = member.TeamID
JOIN Coaches coach ON team.CoachID = coach.CoachID;



-- This creates views for event attendies, split for members and for coaches.
CREATE VIEW MemberEventAttendeesView AS
SELECT 
	event.EventName,  event.EventDate,  event.Location,
	members.MemberName    
FROM 
	Events event
	JOIN MembersEvents membersEvents ON event.EventID = membersEvents.EventID
	JOIN Members members ON membersEvents.MemberID = members.MemberID;


CREATE VIEW CoachEventAttendeesView AS
SELECT 
	event.EventName,  event.EventDate,  event.Location,
	coaches.CoachName
FROM 
	Events event
	JOIN CoachesEvents coachesEvents ON event.EventID = coachesEvents.EventID
	JOIN Coaches coaches ON coachesEvents.CoachID = coaches.CoachID;




-- Populates tables with entries (two per table)
INSERT INTO Coaches (CoachName, ContactInfo, CertificationLevel, Specialization) 
VALUES 
	('James ODonnel', 'Mobile: 082 4412 312', 'Intermediate', 'Hooker'), 
    ('Connor Mitchel', 'Email: ConMit89@somewhere.com', 'National Master', 'Full-back');
    
INSERT INTO Teams (CoachID, TeamName, AgeGroup) 
VALUES 	((SELECT CoachID FROM Coaches WHERE CoachName='James ODonnel'), 'Carlow Horses', "20-26"),  
		((SELECT CoachID FROM Coaches WHERE CoachName='Connor Mitchel'), 'Wild Antlantic Way', "20-26");

INSERT INTO Members (MemberName, ContactInfo, DateOfBirth, JoinDate, MembershipType, PositionPlayed, TeamID) 
VALUES 
	('John Doe', 'Mobile: 088 2349 123', '2000-03-21', '2024-04-01', 'Basic', 'Full-back', (SELECT TeamID FROM Teams WHERE TeamName='Wild Antlantic Way')),
	('Robert Newell', 'Mobile: 088 2451 139', '2001-12-14', '2024-04-01', 'Basic', 'Hooker', (SELECT TeamID FROM Teams WHERE TeamName='Wild Antlantic Way'));


INSERT INTO Matches (HomeTeamID, AwayTeamID, MatchDate, Venue, Results)  
VALUES 
	((SELECT TeamID FROM Teams WHERE TeamName='Carlow Horses'), (SELECT TeamID FROM Teams WHERE TeamName='Wild Antlantic Way'), '2024-04-09', 'SETU Sport Field 3', "44-26"),
    ((SELECT TeamID FROM Teams WHERE TeamName='Wild Antlantic Way'), (SELECT TeamID FROM Teams WHERE TeamName='Carlow Horses'), '2024-05-09', 'ATU Sport Field 1', "45-24");

INSERT INTO Events (EventName, EventType, EventDate, Location)  
VALUES 
	('New Members Party', 'Celebration', '2024-04-03', 'Wild Antlantic Way Rugby Club'),
    ('Training Session', 'Training', '2024-04-20', 'Wild Antlantic Way Rugby Club');
    
-- "Invite" members and coaches to the newly created event   
INSERT INTO MembersEvents (MemberID, EventID)  
VALUES
	((SELECT MemberID FROM Members WHERE MemberName='John Doe'), (SELECT EventID FROM Events WHERE EventName='New Members Party')),
	((SELECT MemberID FROM Members WHERE MemberName='Robert Newell'), (SELECT EventID FROM Events WHERE EventName='New Members Party')),
	((SELECT MemberID FROM Members WHERE MemberName='John Doe'), (SELECT EventID FROM Events WHERE EventName='Training Session')),
	((SELECT MemberID FROM Members WHERE MemberName='Robert Newell'), (SELECT EventID FROM Events WHERE EventName='Training Session'));
 
INSERT INTO CoachesEvents (CoachID, EventID)  
VALUES
	((SELECT CoachID FROM Coaches WHERE CoachName='James ODonnel'), (SELECT EventID FROM Events WHERE EventName='Training Session')),
	((SELECT CoachID FROM Coaches WHERE CoachName='Connor Mitchel'), (SELECT EventID FROM Events WHERE EventName='Training Session'));
    
    SELECT * FROM TeamMembersView;
