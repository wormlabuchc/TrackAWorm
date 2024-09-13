%posix_timestamp = 1.524216883857000e+09;
dt1 = datetime('now','convertfrom','posixtime', 'Format', 'HH:mm:ss.SSS');
dt2 = datetime('now','convertfrom','posixtime', 'Format', 'HH:mm:ss.SSS');
dt3= datetime('now','convertfrom','posixtime', 'Format', 'HH:mm:ss.SSS');
dt = [dt1; dt2; dt3];
worm = [1;2;3];
TT = timetable(datetime(dt),worm);
%TT.Time