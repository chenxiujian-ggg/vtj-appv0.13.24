# ---- 基础镜像 ----
FROM node:22.19.0-bullseye

# ---- 环境变量 ----
ENV PORT=9527
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

# ---- 安装全局依赖 ----
RUN npm install -g lerna@latest pnpm@latest --registry=https://registry.npmmirror.com

# ---- 创建工作目录（项目根） ----
WORKDIR /app

# ---- 把源码复制进来（GitHub Actions 里 checkout 过的源码） ----
COPY . .

# ---- 安装项目依赖 ----
RUN npm run setup

# ---- 构建项目依赖 ----
RUN npm run build

# ---- 构建阶段：预启动 pro:dev，生成缓存后强制退出 ----
RUN BROWSER=none npm run pro:dev -- --host 0.0.0.0 --port 9527 & \
    pid=$! && \
    echo "pro:dev server running, waiting 20 s ..." && \
    sleep 20 && \
    echo "time up, killing pro:dev server" && \
    (kill $pid && wait $pid 2>/dev/null || true)

# ---- 暴露端口 ----
EXPOSE 9527

# ---- 默认启动命令 ----
CMD ["npm", "run", "pro:dev"]
