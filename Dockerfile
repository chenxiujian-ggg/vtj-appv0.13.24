# ---- 基础镜像 ----
FROM node:22.19.0-bullseye

# ---- 环境变量 ----
ENV PORT=9527
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

# ---- 安装全局依赖 ----
RUN npm install -g lerna@latest pnpm@latest

# ---- 创建项目 ----
WORKDIR /app
RUN echo "app" | npm create vtj@latest -- -t app

# ---- 安装依赖 ----
WORKDIR /app/app
RUN npm install

# ---- 构建阶段：只启动 60 秒 → 强制 kill ----
# ---- 构建阶段：启动 60 秒 → 强制 kill（忽略退出码）----
RUN BROWSER=none npm run dev -- --host 0.0.0.0 --port 9527 & \
    pid=$! && \
    echo "dev server running, waiting 60 s ..." && \
    sleep 20 && \
    echo "time up, killing dev server" && \
    (kill $pid && wait $pid 2>/dev/null || true)

# ---- 暴露端口 ----
EXPOSE 9527

# ---- 默认启动命令 ----
CMD ["npm", "run", "dev"]
