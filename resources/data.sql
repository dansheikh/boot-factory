insert into Users (first_name, last_name, email, password)
            Values ('Sam', 'Adams', 'sam.adams@bcgdv.com', 'whoami'),
            ('Paul', 'Revere', 'paul.revere@bcgdv.com', 'pwd'),
            ('John', 'Hancock', 'john.hancock@bcgdv.com', 'mount');

insert into Users (first_name, middle_name, last_name, email, password)
            Values ('John', 'Quincy', 'Adams', 'john.q.adams@bcgdv.com', 'touch');

insert into Accounts (user_id, balance)
            Values (1, 100.00),
            (2, -50.00),
            (3, 1000.00),
            (4, 50.00);
