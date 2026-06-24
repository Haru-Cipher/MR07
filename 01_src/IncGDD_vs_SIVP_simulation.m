% =========================================================================
% IncGDD vs Traditional SIVP Reduction Animation - Clean Layout Version
% 白框資訊移到底部，不遮住上方晶格動畫
% 晶格點改成明亮顏色
% =========================================================================

clear; clc; close all;

bgColor      = [0.07 0.08 0.11];   % 深藍黑
axisBgColor  = [0.03 0.04 0.06];   % 更深的座標背景
textColor    = [0.92 0.94 0.96];   % 淺灰白文字
gridColor    = [0.65 0.70 0.75];   % 柔和格線
boxColor     = [0.11 0.12 0.16];   % 深色資訊框

N = 8;
framesPerStep = 18;
gifName = 'IncGDD_vs_Traditional_SIVP_clean_layout.gif';

gamma = 1.25;
phiB = 0.7;
r = gamma * phiB + 0.25;

g = 1.55;
initialNorm = 8.0;
minNorm = 1.2;

delta0 = 0.92;
pollutionRate = 0.075;

statDistance = zeros(1, N);
successProb = zeros(1, N);

for k = 1:N
    statDistance(k) = min(0.9, (k-1) * pollutionRate);
    successProb(k) = max(0.05, delta0 - statDistance(k));
end

% -------------------------------------------------------------------------
% 2. 建立晶格點與 target
% -------------------------------------------------------------------------
range = -8:8;
[X, Y] = meshgrid(range, range);
latticePoints = [X(:), Y(:)];

target = [2, 2];

theta = linspace(0, 2*pi, N+1);
theta(end) = [];

incNorms = linspace(initialNorm, minNorm, N);
tradNorms = linspace(initialNorm, minNorm, N);

% -------------------------------------------------------------------------
% 3. 設定 IncGDD 與 Traditional 的向量
% -------------------------------------------------------------------------
incVectors = zeros(N, 2);
tradVectors = zeros(N, 2);

% IncGDD 的示意輸出：
% 第一根向量改成 s_1 = (6,0)
% 其餘向量都安排在 target 附近，確保落在黃色圓圈內
incVectors = [
    6  0
    5  1
    4  1
    3  1
    2  1
    2  2
    3  2
    2  3
];

% 如果 N 不是 8，避免資料列數不夠
if N > size(incVectors, 1)
    error('N is larger than the number of predefined IncGDD vectors.');
end

% 只取前 N 根
incVectors = incVectors(1:N, :);

% Traditional SIVP 仍然用從原點出發的方向向量示意
for kk = 1:N
    tradVectors(kk,:) = tradNorms(kk) * [cos(theta(kk)), sin(theta(kk))];
end

figure('Color', [0.08 0.08 0.10], 'Position', [80, 60, 1550, 950]);

frameCounter = 1;

for k = 1:N

    oldIncLen = initialNorm;
    if k > 1
        oldIncLen = incNorms(k-1);
    end
    newIncLen = incNorms(k);

    oldTradLen = initialNorm;
    if k > 1
        oldTradLen = tradNorms(k-1);
    end
    newTradLen = tradNorms(k);

    for f = 1:framesPerStep

        alpha = f / framesPerStep;

        % ------------------------------------------------------------
        % IncGDD 部分
        % currentSNorm 是目前 ||S||，用來控制黃色圓圈半徑
        % currentIncVector 是目前動畫中畫出來的 s
        % ------------------------------------------------------------
        currentSNorm = (1-alpha) * oldIncLen + alpha * newIncLen;

        radius = currentSNorm / g + r;

        if k == 1
            % 第一輪從舊的長向量 (8,0) 收縮到新的 s_1 = (6,0)
            startIncVector = [initialNorm, 0];
        else
            % 後面從上一個 IncGDD 輸出移動到下一個輸出
            startIncVector = incVectors(k-1,:);
        end

        endIncVector = incVectors(k,:);

        currentIncVector = (1-alpha) * startIncVector + alpha * endIncVector;
        % ------------------------------------------------------------
        % Traditional SIVP 部分
        % 這邊仍然只是示意傳統方法逐步找短向量
        % ------------------------------------------------------------
        currentTradLen = (1-alpha) * oldTradLen + alpha * newTradLen;

        currentTradVector = currentTradLen * [cos(theta(k)), sin(theta(k))];

        % ------------------------------------------------------------
        % 機率差距
        % ------------------------------------------------------------
        probGap = delta0 - successProb(k);

        clf;

        % 版面：上方兩張幾何圖，下方兩張資訊圖
        tiledlayout(2, 2, ...
            'TileSpacing', 'compact', ...
            'Padding', 'compact');

        % ================================================================
        % 上排左：IncGDD 幾何動畫，不放白框
        % ================================================================
        ax1 = nexttile(1);
        hold on; grid on; axis equal;

        set(ax1, 'Color', [0.04 0.04 0.04]);
        set(ax1, 'XColor', [0.85 0.85 0.85]);
        set(ax1, 'YColor', [0.85 0.85 0.85]);
        set(ax1, 'GridColor', [0.75 0.75 0.75]);
        set(ax1, 'GridAlpha', 0.35);

        title('IncGDD: target-based short vector search', ...
              'FontSize', 13, 'FontWeight', 'bold', ...
              'Color', [0.1 0.1 0.1]);

        xlabel('2D projection axis 1');
        ylabel('2D projection axis 2');

        xlim([-9, 9]);
        ylim([-9, 9]);

        % 晶格點：改成亮青色，會比黑點明顯很多
        plot(latticePoints(:,1), latticePoints(:,2), '.', ...
             'Color', [0.2 1.0 1.0], ...
             'MarkerSize', 13);

        % target
        plot(target(1), target(2), 'o', ...
             'Color', [1.0 0.25 0.25], ...
             'MarkerSize', 10, ...
             'LineWidth', 2.5);

        text(target(1)+0.25, target(2)+0.25, 'target t', ...
             'FontSize', 11, ...
             'FontWeight', 'bold', ...
             'Color', [1.0 0.25 0.25]);

        % IncGDD 搜尋半徑
        drawCircle(target, radius, '--', [1.0 0.9 0.1]);

        % 只保留非常小的資訊，不使用白框
        text(-8.5, 8.0, sprintf('dim %d / %d', k, N), ...
             'FontSize', 11, ...
             'FontWeight', 'bold', ...
             'Color', [1 1 1]);

        text(-8.5, 7.1, sprintf('radius = %.2f', radius), ...
             'FontSize', 10, ...
             'Color', [1.0 0.9 0.1]);

        % 已找到的短向量
        for j = 1:k-1
            quiver(0, 0, incVectors(j,1), incVectors(j,2), 0, ...
                   'LineWidth', 2.8, ...
                   'MaxHeadSize', 0.45, ...
                   'Color', vectorColor(j));

            text(incVectors(j,1)*1.08, incVectors(j,2)*1.08, ...
                 sprintf('s_%d', j), ...
                 'FontSize', 10, ...
                 'FontWeight', 'bold', ...
                 'Color', vectorColor(j));
        end

        % 當前正在找的新短向量
        quiver(0, 0, currentIncVector(1), currentIncVector(2), 0, ...
               'LineWidth', 4.0, ...
               'MaxHeadSize', 0.55, ...
               'Color', [1.0 1.0 1.0]);

        text(currentIncVector(1)*1.08, currentIncVector(2)*1.08, ...
             sprintf('new s_%d', k), ...
             'FontSize', 12, ...
             'FontWeight', 'bold', ...
             'Color', [1 1 1]);

        % ================================================================
        % 上排右：Traditional SIVP 幾何動畫，不放白框
        % ================================================================
        ax2 = nexttile(2);
        hold on; grid on; axis equal;

        set(ax2, 'Color', [0.04 0.04 0.04]);
        set(ax2, 'XColor', [0.85 0.85 0.85]);
        set(ax2, 'YColor', [0.85 0.85 0.85]);
        set(ax2, 'GridColor', [0.75 0.75 0.75]);
        set(ax2, 'GridAlpha', 0.35);

        title('Traditional SIVP: repeated SIS oracle calls', ...
              'FontSize', 13, 'FontWeight', 'bold', ...
              'Color', [0.1 0.1 0.1]);

        xlabel('2D projection axis 1');
        ylabel('2D projection axis 2');

        xlim([-9, 9]);
        ylim([-9, 9]);

        % 晶格點：一樣改亮
        plot(latticePoints(:,1), latticePoints(:,2), '.', ...
             'Color', [0.2 1.0 1.0], ...
             'MarkerSize', 13);

        text(-8.5, 8.0, sprintf('dim %d / %d', k, N), ...
             'FontSize', 11, ...
             'FontWeight', 'bold', ...
             'Color', [1 1 1]);

        text(-8.5, 7.1, sprintf('SIS calls = %d', k), ...
             'FontSize', 10, ...
             'Color', [1.0 0.9 0.1]);

        % 已找到的短向量
        for j = 1:k-1
            quiver(0, 0, tradVectors(j,1), tradVectors(j,2), 0, ...
                   'LineWidth', 2.8, ...
                   'MaxHeadSize', 0.45, ...
                   'Color', vectorColor(j));

            text(tradVectors(j,1)*1.08, tradVectors(j,2)*1.08, ...
                 sprintf('v_%d', j), ...
                 'FontSize', 10, ...
                 'FontWeight', 'bold', ...
                 'Color', vectorColor(j));
        end

        % 當前正在找的新短向量
        quiver(0, 0, currentTradVector(1), currentTradVector(2), 0, ...
               'LineWidth', 4.0, ...
               'MaxHeadSize', 0.55, ...
               'Color', [1 1 1]);

        text(currentTradVector(1)*1.08, currentTradVector(2)*1.08, ...
             sprintf('new v_%d', k), ...
             'FontSize', 12, ...
             'FontWeight', 'bold', ...
             'Color', [1 1 1]);
        
        % ================================================================
        % 下排左：IncGDD 文字區，不使用 annotation，避免 GIF 閃爍
        % ================================================================
        ax3 = nexttile(3);
        cla(ax3);
        axis(ax3, 'off');

        set(ax3, 'Color', bgColor);

        distToTargetNow = norm(endIncVector - target);
        sNormNow = norm(endIncVector);

        incInfo = {
            'IncGDD information'
            ''
            sprintf('Step / dimension : %d / %d', k, N)
            sprintf('Current ||S||    : %.2f', currentSNorm)
            sprintf('Radius           : %.2f', radius)
            sprintf('||s_k||          : %.2f', sNormNow)
            sprintf('||s_k - t||      : %.2f <= %.2f', distToTargetNow, radius)
            ''
            'Meaning:'
            'Find lattice vector s_k'
            'close to target t.'
            ''
            'Reduction idea:'
            'Call SIS oracle once.'
            'Then use IncGDD repeatedly'
            'as a worst-case tool.'
            };

        text(0.05, 0.95, incInfo, ...
            'Units', 'normalized', ...
            'VerticalAlignment', 'top', ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 10.5, ...
            'FontName', 'Consolas', ...
            'Color', textColor, ...
            'Interpreter', 'none');

        % 進度條
        progress = k / N;

        rectangle('Position', [0.05, 0.06, 0.82, 0.055], ...
            'EdgeColor', textColor, ...
            'LineWidth', 1.2);

        rectangle('Position', [0.05, 0.06, 0.82 * progress, 0.055], ...
            'FaceColor', [0.25 0.65 1.0], ...
            'EdgeColor', 'none');

        text(0.05, 0.15, ...
            sprintf('Short vectors found: %d / %d', k, N), ...
            'Units', 'normalized', ...
            'FontSize', 10.5, ...
            'FontWeight', 'bold', ...
            'Color', textColor, ...
            'Interpreter', 'none');

        % ================================================================
        % 下排右：機率污染圖，放在圖外
        % ================================================================
        ax4 = nexttile(4);
        hold on; grid on;

        set(ax4, 'Color', [0.04 0.04 0.04]);
        set(ax4, 'XColor', [0.85 0.85 0.85]);
        set(ax4, 'YColor', [0.85 0.85 0.85]);
        set(ax4, 'GridColor', [0.75 0.75 0.75]);
        set(ax4, 'GridAlpha', 0.30);

        title('Probability pollution comparison', ...
            'FontSize', 13, ...
            'FontWeight', 'bold', ...
            'Color', [0.92 0.92 0.92]);

        xlabel('Dimension / oracle call', 'Color', [0.92 0.92 0.92]);
        ylabel('Probability / statistical distance', 'Color', [0.92 0.92 0.92]);

        xlim([1, N]);
        ylim([0, 1]);

        plot(1:k, successProb(1:k), '-o', ...
             'LineWidth', 2.8, ...
             'MarkerSize', 7, ...
             'Color', [0.1 0.45 1.0]);

        plot(1:k, statDistance(1:k), '-s', ...
             'LineWidth', 2.8, ...
             'MarkerSize', 7, ...
             'Color', [1.0 0.25 0.25]);

        plot(1:k, delta0 * ones(1,k), '--', ...
             'LineWidth', 2.0, ...
             'Color', [0.1 0.7 0.2]);
    
        lgd = legend( ...
            'Traditional success prob.', ...
            'Traditional stat. distance', ...
            'IncGDD single-call baseline', ...
            'Location', 'eastoutside');

        set(lgd, ...
            'TextColor', textColor, ...
            'Color', boxColor, ...
            'EdgeColor', [0.65 0.65 0.65], ...
            'FontSize', 9);

        % 目前點
        plot(k, successProb(k), 'o', ...
             'MarkerSize', 11, ...
             'LineWidth', 2.5, ...
             'Color', [0.1 0.45 1.0]);

        plot(k, statDistance(k), 's', ...
             'MarkerSize', 11, ...
             'LineWidth', 2.5, ...
             'Color', [1.0 0.25 0.25]);

        % 機率資訊放在右下圖內，但不會遮住上面幾何動畫
        probInfo = {
            sprintf('Step %d:', k)
            sprintf('Traditional SIS calls: %d', k)
            sprintf('Initial success prob: %.3f', delta0)
            sprintf('Current success prob: %.3f', successProb(k))
            sprintf('Statistical distance: %.3f', statDistance(k))
            sprintf('Probability gap: %.3f', probGap)
        };

        text(0.56, 0.90, probInfo, ...
             'Units', 'normalized', ...
             'VerticalAlignment', 'top', ...
             'FontSize', 10, ...
             'Color', [0.92 0.92 0.92], ...
             'BackgroundColor', [0.12 0.12 0.14], ...
             'EdgeColor', [0.65 0.65 0.65]);

        % ================================================================
        % 總標題
        % ================================================================
        sgtitle(sprintf('IncGDD vs Traditional SIVP Reduction | Step %d of %d', k, N), ...
        'FontSize', 16, ...
        'FontWeight', 'bold', ...
        'Color', [0.92 0.92 0.92]);

        drawnow;

        % 寫入 GIF
        frame = getframe(gcf);
        img = frame2im(frame);
        [A, map] = rgb2ind(img, 256);

        if frameCounter == 1
            imwrite(A, map, gifName, 'gif', ...
                    'LoopCount', Inf, ...
                    'DelayTime', 0.08);
        else
            imwrite(A, map, gifName, 'gif', ...
                    'WriteMode', 'append', ...
                    'DelayTime', 0.08);
        end

        frameCounter = frameCounter + 1;
    end
end

disp(['GIF saved as: ', gifName]);

% =========================================================================
% 畫圓函數
% =========================================================================
function drawCircle(center, radius, lineStyle, colorValue)
    ang = linspace(0, 2*pi, 300);
    x = center(1) + radius * cos(ang);
    y = center(2) + radius * sin(ang);

    plot(x, y, lineStyle, ...
         'Color', colorValue, ...
         'LineWidth', 2.0);
end

% =========================================================================
% 向量顏色函數
% =========================================================================
function c = vectorColor(j)
    colorList = [
        1.00 0.35 0.35
        0.35 1.00 0.35
        0.35 0.85 1.00
        1.00 0.35 0.90
        1.00 0.65 0.20
        0.70 0.45 1.00
        1.00 1.00 0.30
        0.30 1.00 0.85
    ];

    idx = mod(j-1, size(colorList,1)) + 1;
    c = colorList(idx,:);
end
