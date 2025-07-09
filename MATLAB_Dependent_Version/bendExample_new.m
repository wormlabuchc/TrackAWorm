data = readmatrix('bendExample_acr_12_04.xlsx'); % Replace with your file name
x = data(:, 1); % First column (Column A)
y = data(:, 2); % Second column (Column B)

% plot(x, y);
% xlabel('Column A'); % Label for x-axis
% ylabel('Column B'); % Label for y-axis
% title('Plot of Column B vs Column A');
% grid on; % Optional: Add grid lines

x1 = data(:, 1); % First column (Column A)
y1 = data(:, 2); % Second column (Column B)

% % Define smoothing window size (adjust based on noise level)
% window_size = 5; % Odd integer (e.g., 3, 5, 7)
% smoothed_y = movmean(y1, window_size);
% 
% % Plot original vs. smoothed data
% plot(x1, y1, 'b-', 'LineWidth', 1, 'DisplayName', 'Original');
% hold on;
% plot(x1, smoothed_y, 'r-', 'LineWidth', 1, 'DisplayName', 'Smoothed');
% xlabel('Column A');
% ylabel('Column B');
% title('Smoothed vs. Original Data');
% legend('show');
% grid on;

% % Define Savitzky-Golay parameters
% order = 2;    % Polynomial order (e.g., 2 or 3)
% window = 7;  % Window size (odd integer, larger for more smoothing)
% smoothed_y = sgolayfilt(y1, order, window);
% 
% % Plot results (same as above)
% plot(x1, y1, 'b-', 'LineWidth', 1, 'DisplayName', 'Original');
% hold on;
% plot(x1, smoothed_y, 'r-', 'LineWidth', 1, 'DisplayName', 'Smoothed');
% xlabel('Column A');
% ylabel('Column B');
% title('Savitzky-Golay Smoothed Data');
% legend('show');
% grid on;

% Parameters (adjust these based on your data)
threshold = 10;       % Define "near zero" (e.g., |y| < 0.5)
transition_width = 0.2; % Smooth transition width around threshold
smoothing_window = 7;  % Window size for smoothing (odd integer)

% Step 1: Smooth the entire signal (temporarily)
smoothed_y = movmean(y, smoothing_window);

% Step 2: Create a blending weight matrix

weight = 1 ./ (1 + exp(20*(abs(y) - threshold))); % Sigmoid transition


% Step 3: Blend original and smoothed data
blended_y = weight .* smoothed_y + (1 - weight) .* y;

% Step 4: Plot results
figure;
plot(x, y, 'b-', 'LineWidth', 1, 'DisplayName', 'Original');
hold on;
plot(x, blended_y, 'r-', 'LineWidth', 1, 'DisplayName', 'Selectively Smoothed');
xlabel('Column A');
ylabel('Column B');
title('Selective Smoothing Near y=0');
legend('show');
grid on;