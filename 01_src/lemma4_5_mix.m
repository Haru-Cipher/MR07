% =========================================================================
% 宏觀與微觀的結合：Lemma 4.5 3D地圖與單位圓相消干涉 同步動畫
% =========================================================================
clear; clc; close all;

% -------------------------------------------------------------------------
% 1. 參數設定 (與您原本的設定相近)
% -------------------------------------------------------------------------
n = 2;              % 2D 空間
s = 4;              % 高斯平滑參數
c = [0.3, 0.6];     % 高斯中心
range = -15:15;     % 晶格取樣範圍 (稍微縮小以加快動畫運算)
[X1, X2] = meshgrid(range, range);

% 計算機率權重 prob (不隨 v 改a變)
dist2 = (X1 - c(1)).^2 + (X2 - c(2)).^2;
rho = exp(-pi * dist2 / s^2);
prob = rho / sum(rho, 'all');

% -------------------------------------------------------------------------
% 2. 預先計算 3D 曲面資料 (左側地圖底圖)
% -------------------------------------------------------------------------
v_grid = 0:0.02:1;
[V1_grid, V2_grid] = meshgrid(v_grid, v_grid);
Eabs = zeros(size(V1_grid));

for a = 1:size(V1_grid,1)
    for b = 1:size(V1_grid,2)
        phase_grid = X1 * V1_grid(a,b) + X2 * V2_grid(a,b);
        Eabs(a,b) = abs(sum(exp(2*pi*1i*phase_grid) .* prob, 'all'));
    end
end

% -------------------------------------------------------------------------
% 3. 初始化畫布 (1x2 雙視窗版面)
% -------------------------------------------------------------------------
fig = figure('Color', [0.1 0.1 0.1], 'Position', [50, 100, 1200, 550]);

% --- 左視窗：3D 宏觀地圖 ---
subplot(1, 2, 1);
surf(V1_grid, V2_grid, Eabs, 'EdgeAlpha', 0.3);
hold on; grid on; colormap('parula');
set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
xlabel('$v_1$', 'Interpreter', 'latex', 'FontSize', 12, 'Color', 'w');
ylabel('$v_2$', 'Interpreter', 'latex', 'FontSize', 12, 'Color', 'w');
zlabel('$|E[\exp(2\pi i \langle \mathbf{x},\mathbf{v} \rangle)]|$', 'Interpreter', 'latex', 'FontSize', 12, 'Color', 'w');
title('Macro Map: The 3D Surface', 'Color', 'w', 'FontSize', 14);
view(-35, 45); % 設定 3D 視角

% 在 3D 圖上建立一個動態移動的追蹤球 (Tracker) 與一根連接底部的線
h_tracker_line = plot3([0 0], [0 0], [0 0], 'w--', 'LineWidth', 1.5);
h_tracker_ball = plot3(0, 0, 0, 'wo', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

% --- 右視窗：2D 微觀機制 ---
subplot(1, 2, 2);
hold on; axis equal; grid on;
set(gca, 'Color', [0.1 0.1 0.1], 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5], 'GridColor', [0.4 0.4 0.4]);
xlim([-1.3 1.3]); ylim([-1.3 1.3]);
plot(cos(linspace(0, 2*pi, 200)), sin(linspace(0, 2*pi, 200)), '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);

% 右側動態物件：圓圈、中心點、紅箭頭
marker_sizes = prob(:) * 20000 + 10; % 將 prob 攤平並放大以顯示圓圈
h_outer = scatter([], [], [], [], 'filled', 'MarkerFaceAlpha', 0.6); 
h_inner = scatter([], [], 15, [0.2 0.2 1.0], 'filled');
h_arrow = quiver(0, 0, 0, 0, 0, 'r', 'LineWidth', 3, 'MaxHeadSize', 1.5);
h_title_right = title('', 'Interpreter', 'latex', 'Color', 'w', 'FontSize', 13);

% -------------------------------------------------------------------------
% 4. 設定動畫路徑與 GIF 輸出
% -------------------------------------------------------------------------
% 讓探測器沿著對角線從 (0,0) [最高峰] 走向 (1,1) [最高峰]，中間會經過深藍平原
t_steps = linspace(0, 1, 120); 
filename = 'Lemma45_Combined_View.gif';
frame_idx = 1;

for t = t_steps
    if ~ishandle(fig), break; end
    
    % 當前位置 v = (v1, v2)
    v1 = t; 
    v2 = t; 
    
    % --- 計算微觀相位與期望值 ---
    phase_matrix = X1 * v1 + X2 * v2;
    complex_vals = exp(2j * pi * phase_matrix);
    expectation = sum(complex_vals .* prob, 'all');
    current_Eabs = abs(expectation);
    
    % --- 更新左側 3D 地圖的追蹤器 ---
    set(h_tracker_ball, 'XData', v1, 'YData', v2, 'ZData', current_Eabs);
    set(h_tracker_line, 'XData', [v1 v1], 'YData', [v2 v2], 'ZData', [0 current_Eabs]);
    
    % --- 更新右側 2D 單位圓的圖形 ---
    phases_flat = complex_vals(:); % 攤平成一維以利 scatter 繪圖
    set(h_outer, 'XData', real(phases_flat), 'YData', imag(phases_flat), 'SizeData', marker_sizes, 'CData', prob(:));
    set(h_inner, 'XData', real(phases_flat), 'YData', imag(phases_flat));
    set(h_arrow, 'UData', real(expectation), 'VData', imag(expectation));
    
    % 更新右側標題
    title_str = sprintf('Micro Mechanics: $e^{2\\pi i \\langle \\mathbf{x}, \\mathbf{v} \\rangle}$\\\\$\\mathbf{v} = (%.2f, %.2f) \\quad |\\mathrm{Exp}| = %.4f$', v1, v2, current_Eabs);
    set(h_title_right, 'String', title_str);
    
    drawnow;
    
    % --- 寫入 GIF ---
    frame = getframe(fig);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    if frame_idx == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.05);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
    end
    frame_idx = frame_idx + 1;
end

disp(['✅ 綜合視角 GIF 動畫已成功儲存為: ', fullfile(pwd, filename)]);
