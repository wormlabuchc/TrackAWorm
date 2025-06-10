figure; 
hold on; 
axis equal; 

% Sample data for demonstration
xPlot = linspace(0, 10, 50);
yPlot = sin(xPlot); 

% Plot the line segments with gray color by default
plot(xPlot, yPlot, 'color', [0.5 0.5 0.5], 'LineWidth', 1)

% Plot the starting point with a red X
plot(xPlot(1), yPlot(1), 'X', 'MarkerFaceColor', 'r', 'MarkerSize', 15, 'LineWidth', 2);

title('Worm path (''X'' marks the starting point)')
xlabel('x position (um)');
ylabel('y position (um)');

% Color line segments differently based on the difference between consecutive x-coordinates
for i = 1:length(xPlot)-1
    if xPlot(i+1) - xPlot(i) < 0
        plot(xPlot(i:i+1), yPlot(i:i+1), 'color', 'r', 'LineWidth', 1); % Color segments with negative x difference as red
    end
end

% Add scatter plot if needed
% scatter(xPlot, yPlot, 20, 'filled', 'MarkerFaceColor', '#0072BD');
