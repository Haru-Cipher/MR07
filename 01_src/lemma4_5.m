% Lemma 4.5: 匯出 GIF 動畫檔 (標題顯示純文字 LaTeX 碼)
clear; clc; close all;

% ==========================================
% 1. 參數設定與畫布初始化
% ==========================================
s = 2.5; c = 0; x = -15:15;
weights = exp(-pi * ((x - c).^2) / (s^2));
weights = weights / sum(weights);
marker_sizes = weights * 5000 + 20;

fig = figure('Color', [0.1 0.1 0.1], 'Position', [150, 150, 800, 600]); 
hold on; axis equal; grid on;
set(gca, 'Color', [0.1 0.1 0.1], 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5], 'GridColor', [0.4 0.4 0.4]);
xlim([-1.3 1.3]); ylim([-1.3 1.3]);

plot(cos(linspace(0, 2*pi, 200)), sin(linspace(0, 2*pi, 200)), '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);

h_outer = scatter([], [], [], [], 'filled', 'MarkerFaceAlpha', 0.7); colormap('parula');
h_inner = scatter([], [], 25, [0.2 0.2 1.0], 'filled');
h_arrow = quiver(0, 0, 0, 0, 0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 2);

% ==========================================
% 2. GIF 檔案設定
% ==========================================
filename = 'Lemma45_Animation_LaTeX_Title.gif'; 
v_steps = linspace(0, 1, 150);       
frame_idx = 1;                       

% ==========================================
% 3. 動態迴圈與 GIF 寫入
% ==========================================
for v = v_steps
    if ~ishandle(fig), break; end

    % 計算數值
    inner_products = x * v;
    phases = exp(2j * pi * inner_products);
    expected_value = sum(weights .* phases);

    % 更新圖形
    set(h_outer, 'XData', real(phases), 'YData', imag(phases), 'SizeData', marker_sizes, 'CData', weights);
    set(h_inner, 'XData', real(phases), 'YData', imag(phases));
    set(h_arrow, 'UData', real(expected_value), 'VData', imag(expected_value));

    % --- 修改點：將標題分為兩行字串陣列，並關閉 Interpreter ---
    % 注意：在 sprintf 中需要用 \\ 來輸出單一個 \ 符號
    % 1. 第一行標題：純靜態字串，直接寫單斜線即可，不要用 sprintf
    title_line1 = 'Weighted average of $e^{2\pi i \langle x, v \rangle}$';

    % 2. 第二行標題：帶入變數，必須用 sprintf，且 LaTeX 指令要用雙斜線 \\
    title_line2 = sprintf('$v = %.3f \\quad |\\mathrm{Exp}| = %.4f$', v, abs(expected_value));

    % 3. 輸出標題：用大括號 {} 包起來換行，外部指定白色與 latex 解析器
    title({title_line1, title_line2}, 'Interpreter', 'latex', 'Color', 'w', 'FontSize', 14);
 
    % -----------------------------------------------------------

    drawnow;

    % 擷取畫面並寫入 GIF
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

disp(['✅ GIF 動畫已成功儲存為: ', fullfile(pwd, filename)]);