clear; clc; close all;

%% =========================
% Basic setting
%% =========================

c = [0.7, 0.4];      % center c in R^2

u = [1, 1];          % unit vector u
u = u / norm(u);

j = 2;               % second moment

s_min = 0.8;
s_max = 8;
numFrames = 160;

sList = linspace(s_min, s_max, numFrames);

secondMomentList = zeros(size(sList));
targetList = zeros(size(sList));
errorList = zeros(size(sList));

%% =========================
% GIF setting
%% =========================

gifName = 'second_moment_double_peak.gif';
delayTime = 0.04;

%% =========================
% Use a large fixed lattice range
% Important: large enough for s_max
%% =========================

R = ceil(8 * s_max + max(abs(c)));
range = -R:R;

[X1, X2] = meshgrid(range, range);

DX1 = X1 - c(1);
DX2 = X2 - c(2);

dist2 = DX1.^2 + DX2.^2;

inner = DX1 * u(1) + DX2 * u(2);

%% =========================
% Initial frame
%% =========================

s = sList(1);

rho = exp(-pi * dist2 / s^2);
rho_Lambda = sum(rho, "all");
prob = rho / rho_Lambda;

value = (inner.^j) .* prob;

second_moment = sum(value, "all");
target = s^2 / (2*pi);
error_value = abs(second_moment - target);

secondMomentList(1) = second_moment;
targetList(1) = target;
errorList(1) = error_value;

%% =========================
% Figure layout
%% =========================

fig = figure;
set(fig, 'Position', [100, 100, 1200, 500]);

%% Left plot: double-peak valley contribution
subplot(1,2,1);

hSurf = surf(X1, X2, value);
shading interp;

xlabel('$x_1$', 'Interpreter', 'latex');
ylabel('$x_2$', 'Interpreter', 'latex');
zlabel('$\langle x-c,u\rangle^2 D_{\Lambda,s,c}(x)$', ...
    'Interpreter', 'latex');

title({ ...
    '$\langle x-c,u\rangle^2 \cdot \frac{\rho_{s,c}(x)}{\rho_{s,c}(\Lambda)}$', ...
    sprintf('$s = %.2f$', s) ...
    }, ...
    'Interpreter', 'latex', ...
    'FontSize', 12);

grid on;
hold on;

% Mark center c
plot3(c(1), c(2), 0, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(c(1), c(2), 0, '  c', 'FontSize', 12);

% Draw unit vector u
scale = 4;
quiver3(c(1), c(2), 0, ...
        scale*u(1), scale*u(2), 0, ...
        'r', 'LineWidth', 3, 'MaxHeadSize', 1);

view(45, 30);
colorbar;

% Fix z-axis for stable animation
zMax = 0.12;
zlim([0, zMax]);
caxis([0, zMax]);

hold off;

%% Right plot: sum value vs target
subplot(1,2,2);

hSecond = plot(sList(1), secondMomentList(1), 'o-', 'LineWidth', 2);
hold on;
hTarget = plot(sList(1), targetList(1), '--', 'LineWidth', 2);
hError = plot(sList(1), errorList(1), ':', 'LineWidth', 2);

grid on;

xlabel('$s$', 'Interpreter', 'latex');
ylabel('Value');

title({ ...
    'Total second moment compared with target', ...
    '$\sum_x \langle x-c,u\rangle^2 D_{\Lambda,s,c}(x)$ vs. $\frac{s^2}{2\pi}$' ...
    }, ...
    'Interpreter', 'latex', ...
    'FontSize', 12);

legend('Second moment sum', '$s^2/(2\pi)$', 'Absolute error', ...
    'Interpreter', 'latex', ...
    'Location', 'northwest');

xlim([s_min, s_max]);
ylim([0, s_max^2/(2*pi)*1.2]);

hText = text(s_min, s_max^2/(2*pi), ...
    sprintf('s = %.2f\nSecond moment = %.6f\nTarget = %.6f\nError = %.6f', ...
    s, second_moment, target, error_value), ...
    'Interpreter', 'none', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');

hold off;

%% =========================
% Animation loop + save GIF
%% =========================

for k = 1:numFrames

    s = sList(k);

    rho = exp(-pi * dist2 / s^2);
    rho_Lambda = sum(rho, "all");
    prob = rho / rho_Lambda;

    value = (inner.^j) .* prob;

    second_moment = sum(value, "all");
    target = s^2 / (2*pi);
    error_value = abs(second_moment - target);

    secondMomentList(k) = second_moment;
    targetList(k) = target;
    errorList(k) = error_value;

    %% Update left plot
    subplot(1,2,1);

    set(hSurf, 'ZData', value, 'CData', value);

    title({ ...
        '$\langle x-c,u\rangle^2 \cdot \frac{\rho_{s,c}(x)}{\rho_{s,c}(\Lambda)}$', ...
        sprintf('$s = %.2f$', s) ...
        }, ...
        'Interpreter', 'latex', ...
        'FontSize', 12);

    %% Update right plot
    subplot(1,2,2);

    set(hSecond, ...
        'XData', sList(1:k), ...
        'YData', secondMomentList(1:k));

    set(hTarget, ...
        'XData', sList(1:k), ...
        'YData', targetList(1:k));

    set(hError, ...
        'XData', sList(1:k), ...
        'YData', errorList(1:k));

    set(hText, ...
        'String', sprintf('s = %.2f\nSecond moment = %.6f\nTarget = %.6f\nError = %.6f', ...
        s, second_moment, target, error_value), ...
        'Position', [s_min, s_max^2/(2*pi)]);

    drawnow;

    %% Capture frame
    frame = getframe(fig);
    img = frame2im(frame);
    [A, map] = rgb2ind(img, 256);

    %% Write GIF
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