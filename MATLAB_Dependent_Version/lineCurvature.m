function r=lineCurvature(x,y)

 mx = mean(x); my = mean(y);
 X = x - mx; Y = y - my; % Get differences from means
 dx2 = mean(X.^2); dy2 = mean(Y.^2); % Get variances
 t = [X,Y]\(X.^2-dx2+Y.^2-dy2)/2; % Solve least mean squares problem
 a0 = t(1); b0 = t(2); % t is the 2 x 1 solution array [a0;b0]
 r = sqrt(dx2+dy2+a0^2+b0^2); % Calculate the radius
 a = a0 + mx; b = b0 + my; % Locate the circle's center
 curv = 1/r; % Get the curvature
 
 plot(a,b)
 thetas=0:.05:2*pi;
 cx=a+r*cos(thetas);
 cy=b+r*sin(thetas);
 plot(cx,cy);