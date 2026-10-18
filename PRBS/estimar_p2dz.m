% ==============================================================================
% ITEM 2: ESTIMAÇÃO DO MODELO P2DZ (PROCEST + VALIDAÇÃO CRUZADA)
% ==============================================================================
clear; clc; close all;

% 0. Verificação do System Identification Toolbox
if exist('iddata', 'file') ~= 2 && exist('iddata', 'builtin') ~= 5
    error('❌ O script requer a System Identification Toolbox instalada no MATLAB.\n   Instale-a via: MATLAB > Home > Add-Ons > Get Add-Ons > System Identification Toolbox.');
end

% 1. Carrega os dados preparados no Item 1
if exist('ma31500.mat', 'file')
    load('ma31500.mat');
    fprintf('✅ Arquivo ma31500.mat carregado com sucesso.\n');
else
    error('❌ Arquivo ma31500.mat não encontrado! Execute o script do Item 1 primeiro.');
end

% Extrai os sinais em pequenos sinais (média zero)
y = ma.signals(1).values; % Temp do processo (desvio, média zero)
u = ma.signals(2).values; % PWM (desvio, média zero)
Ts = 1;                   % Período de amostragem de 1 segundo

% 2. Separação de dados para Validação Cruzada (75% Estimação, 25% Validação)
N_total = length(y);
N_est   = round(0.75 * N_total);

dados_est = iddata(y(1:N_est), u(1:N_est), Ts);
dados_val = iddata(y(N_est+1:end), u(N_est+1:end), Ts);

% 3. Estimativa preliminar do Atraso de Transporte (Td)
td_estimado = delayest(dados_est);
fprintf('Atraso preliminar pelo delayest: %.2f s\n', td_estimado);

% 4. Configuração da estrutura P2DZ no procest
% 'P2DZ': 2 Polos, 1 Zero, Delay (Atraso de transporte)
modelo_proc = idproc('P2DZ');

% --- Restrições e inicialização física do sistema térmico ---
% Atraso de transporte do LM35: delimitado obrigatoriamente entre 3s e 8s
modelo_proc.Structure.Td.Value   = 5;   % Estimativa inicial física
modelo_proc.Structure.Td.Minimum = 3;   % Limite físico inferior (3 segundos)
modelo_proc.Structure.Td.Maximum = 8;   % Limite físico superior (8 segundos)

% Polo rápido de aquecimento dos resistores de 150 ohms (esperado: 20s a 50s)
modelo_proc.Structure.Tp1.Value   = 35;
modelo_proc.Structure.Tp1.Minimum = 15;
modelo_proc.Structure.Tp1.Maximum = 60;

% Polo lento do ambiente e zero térmico
modelo_proc.Structure.Tp2.Value   = 250;
modelo_proc.Structure.Tp2.Minimum = 80;
modelo_proc.Structure.Tz.Value    = 70;

% 5. Executa a Estimação via Mínimos Quadrados / procest
fprintf('\nExecutando o procest para estimar Kp, Tz, Tp1, Tp2 e Td...\n');
sys_p2dz = procest(dados_est, modelo_proc);

% 6. Exibe a Função de Transferência Identificada no Terminal
fprintf('\n==================================================\n');
fprintf('   MODELO P2DZ IDENTIFICADO (FUNÇÃO DE TRANSFERÊNCIA)   \n');
fprintf('==================================================\n');
tf_p2dz = tf(sys_p2dz);
disp(tf_p2dz);

% Extração direta dos parâmetros (como números escalares double)
Kp  = sys_p2dz.Kp;
Tp1 = sys_p2dz.Tp1;
Tp2 = sys_p2dz.Tp2;
Tz  = sys_p2dz.Tz;
Td  = sys_p2dz.Td;

fprintf('Kp  = %.4f\n', Kp);
fprintf('Tp1 = %.2f s (Esperado: 20 a 50s)\n', Tp1);
fprintf('Tp2 = %.2f s (Esperado: 200 a 400s)\n', Tp2);
fprintf('Tz  = %.2f s (Esperado: intermediário entre Tp1 e Tp2)\n', Tz);
fprintf('Td  = %.2f s (Esperado: 3 a 8s)\n', Td);

% 7. Validação Cruzada e Cálculo do Fitness %
[y_sim, fit_est, ~] = compare(dados_est, sys_p2dz);
[y_val, fit_val, ~] = compare(dados_val, sys_p2dz);

% Garante formato escalar para exibição no fprintf
fit_est = fit_est(1);
fit_val = fit_val(1);

fprintf('\n--------------------------------------------------\n');
fprintf('Fitness (Estimação - 75%% dos dados): %.2f%%\n', fit_est);
fprintf('Fitness (Validação  - 25%% dos dados): %.2f%%\n', fit_val);
fprintf('--------------------------------------------------\n');

if fit_val >= 90
    fprintf('✅ EXCELENTE: Fitness superior a 90%%! Modelo altamente confiável.\n');
else
    fprintf('⚠️ ATENÇÃO: Fitness abaixo de 90%%. Verifique ruídos ou inconsistências na montagem.\n');
end

% 8. Plotagem dos Gráficos de Validação
figure('Name', 'Validação do Modelo P2DZ - Resposta Identificada vs Medida');
compare(dados_val, sys_p2dz);
grid on;
title(sprintf('Validação Cruzada P2DZ (Fitness: %.2f%%)', fit_val));
saveas(gcf,'ValidacaoP2DZ.png')