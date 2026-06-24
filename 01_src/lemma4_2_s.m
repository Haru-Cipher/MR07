clear; clc; close all;

%% =========================
% Basic setting
%% =========================

range = -12:12;        % lattice range
c = [0.7, 0.4];        % center c in R^2

% Fixed unit vector u
u = [1, 1];
u = u / norm(u);

% Generate 2D lattice Lambda = Z^2
[X1, X2] = meshgrid(range, range);

% Compute x - c
DX1 = X1 - c(1);
DX2 = X2 - c(2);

% Compute <x-c,u>
inner = DX1 * u(1) + DX2 * u(2);

% Compute ||x-c||^2
dist2 = DX1.^2 + DX2.^2;

%% =========================
% Animation setting: s increases
%% =========================

s_min = 0.8;
s_max = 8;
numFrames = 160;

sList = linspace(s_min, s_max, numFrames);

%% =========================
% GIF setting
%% =========================

gifName = 'first_moment_s_animation.gif';
delayTime = 0.04;   % 每一幀間隔時間，單位是秒

%% =========================
% Initial frame
%% =========================

s = sList(1);

rho = exp(-pi * dist2 / s^2);
rho_Lambda = sum(rho, "all");
prob = rho / rho_Lambda;

% First moment contribution
value = inner .* prob;

first_moment = sum(value, "all");

%% =========================
% Plot initialization
%% =========================

hSurf = surf(X1, X2, value);

xlabel('$x_1$', 'Interpreter', 'latex');
ylabel('$x_2$', 'Interpreter', 'latex');
zlabel('$\langle x-c,u\rangle \cdot D_{\Lambda,s,c}(x)$', ...
    'Interpreter', 'latex');

title('$\langle x-c,u\rangle \cdot \frac{\rho_{s,c}(x)}{\rho_{s,c}(\Lambda)}$', ...
    'Interpreter', 'latex');

grid on;
hold on;

% Zero plane
surf(X1, X2, zeros(size(value)), ...
    'FaceAlpha', 0.25, ...
    'EdgeColor', 'none');

% Mark center c
plot3(c(1), c(2), 0, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(c(1), c(2), 0, '  c', 'FontSize', 12);

% Draw unit vector u from center c
scale = 3;
quiver3(c(1), c(2), 0, ...
        scale*u(1), scale*u(2), 0, ...
        'r', 'LineWidth', 3, 'MaxHeadSize', 1);

% Text information
hText = text(min(range), max(range), max(value(:)), ...
    sprintf('s = %.2f\nE[<x-c,u>] = %.8f', s, first_moment), ...
    'FontSize', 12, 'FontWeight', 'bold');

% Fixed axis range for stable animation
zMax = 0.08;
zlim([-zMax, zMax]);
caxis([-zMax, zMax]);

view(45, 30);
colorbar;

hold off;

%% =========================
% Animation loop + save GIF
%% =========================

for k = 1:numFrames

    s = sList(k);

    % Update Gaussian weight
    rho = exp(-pi * dist2 / s^2);
    rho_Lambda = sum(rho, "all");
    prob = rho / rho_Lambda;

    % First moment contribution
    value = inner .* prob;

    % First moment expectation
    first_moment = sum(value, "all");

    % Update surface
    set(hSurf, 'ZData', value, 'CData', value);

    % Update text
    set(hText, ...
        'String', sprintf('s = %.2f\nE[<x-c,u>] = %.8f', s, first_moment), ...
        'Position', [min(range), max(range), zMax]);

    title(sprintf('First moment contribution, s = %.2f', s));

    drawnow;

    %% Capture current frame
    frame = getframe(gcf);
    img = frame2im(frame);
    [A, map] = rgb2ind(img, 256);

    %% Write to GIF
    if k == 1
        imwrite(A, map, gifName, 'gif', ...
            'LoopCount', Inf, ...
            'DelayTime', delayTime);
    else
        imwrite(A, map, gifName, 'gif', ...
            'WriteMode', 'append', ...
            'DelayTime', delayTime);
    end
end

fprintf("GIF saved as: %s\n", gifName);