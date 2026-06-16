% Lemma 4.5: 觀察平滑參數 s 變動的動態動畫 (匯出為 GIF 檔)
clear; clc; close all;

% ==========================================
% 1. 固定參數設定
% ==========================================
c = 0;           % 高斯分佈中心
x = -15:15;      % 一維晶格點取樣範圍
v = 0.5;         % 固定 v 在最完美打散相位的位置 (距離對偶晶格最遠)

% ==========================================
% 2. 初始化畫布
% ==========================================
fig = figure('Color', [0.1 0.1 0.1], 'Position', [150, 150, 800, 600]); 
hold on; axis equal; grid on;
set(gca, 'Color', [0.1 0.1 0.1], 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5], 'GridColor', [0.4 0.4 0.4]);

xlim([-1.3 1.3]); ylim([-1.3 1.3]);

% 繪製單位圓
theta = linspace(0, 2*pi, 200);
plot(cos(theta), sin(theta), '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);

% 初始化動態繪圖物件
h_outer = scatter([], [], [], [], 'filled', 'MarkerFaceAlpha', 0.7); colormap('parula');
h_inner = scatter([], [], 25, [0.2 0.2 1.0], 'filled');
h_arrow = quiver(0, 0, 0, 0, 0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 2);

% 因為 v 固定，點在單位圓上的位置也是固定的，可以直接先算好
inner_products = x * v;                 
phases = exp(2j * pi * inner_products); 
set(h_inner, 'XData', real(phases), 'YData', imag(phases));

% ==========================================
% 3. GIF 檔案設定
% ==========================================
filename = 'Lemma45_Varying_s.gif';  % 設定輸出的檔名
s_steps = linspace(0.2, 3.5, 150);   % 取 150 幀以控制 GIF 檔案大小
frame_idx = 1;

% ==========================================
% 4. 動態演進：讓 s 從小變大，並寫入 GIF
% ==========================================
for s = s_steps
    if ~ishandle(fig), break; end
    
    % 當 s 改變時，重新計算高斯權重 (圓圈大小)
    weights = exp(-pi * ((x - c).^2) / (s^2));
    weights = weights / sum(weights); % 標準化
    marker_sizes = weights * 5000 + 20; 
    
    % 重新計算期望值 (加權平均箭頭)
    expected_value = sum(weights .* phases);
    
    % 即時更新圖形 
    set(h_outer, 'XData', real(phases), 'YData', imag(phases), 'SizeData', marker_sizes, 'CData', weights);
    set(h_arrow, 'UData', real(expected_value), 'VData', imag(expected_value));
    
    % 更新 LaTeX 標題
    title_line1 = 'Weighted average of $e^{2\pi i \langle x, v \rangle}$';
    title_line2 = sprintf('Fixed $v = 0.500 \\quad s = %.3f \\quad |\\mathrm{Exp}| = %.4f$', s, abs(expected_value));
    title({title_line1, title_line2}, 'Interpreter', 'latex', 'Color', 'w', 'FontSize', 14);
    
    drawnow;
    
    % --- 擷取畫面並寫入 GIF ---
    frame = getframe(fig);                     
    im = frame2im(frame);                      
    [imind, cm] = rgb2ind(im, 256);            
    
    if frame_idx == 1
        % 第一幀：建立新檔案，設定無限循環
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.05);
    else
        % 後續幀：附加到同一檔案
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
    end
    
    frame_idx = frame_idx + 1;
end

disp(['✅ 觀察平滑參數 s 變動的 GIF 動畫已成功儲存為: ', fullfile(pwd, filename)]);