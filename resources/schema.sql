create table Users
(
  id int not null generated always as identity,
  first_name char(254) not null,
  middle_name char(254) default null,
  last_name char(254) not null,
  email char(254) not null,
  password char(254) not null,
  primary key (id),
  constraint uq_email unique(email)
);

create table Accounts
(
  id int not null generated always as identity,
  user_id int not null,
  balance decimal default 0.0,
  primary key (id),
  constraint fk_account_user foreign key (user_id) references Users(id) on delete cascade
);