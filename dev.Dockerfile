FROM node:19-alpine
RUN apk update && apk add --no-cache openssl

ARG NEXTAUTH_PUBLIC_GUEST_KEY
ARG NEXTAUTH_SECRET
ARG NEXTAUTH_URL
ARG DATABASE_URL
ARG NEXT_PUBLIC_WEB_SEARCH_ENABLED
ARG SERP_API_KEY
ARG OPENAI_API_KEY
ARG SKIP_ENV_VALIDATION


ENV NEXTAUTH_PUBLIC_GUEST_KEY=$NEXTAUTH_PUBLIC_GUEST_KEY
ENV NEXTAUTH_SECRET=$NEXTAUTH_SECRET
ENV NEXTAUTH_URL=$NEXTAUTH_URL
ENV DATABASE_URL=$DATABASE_URL
ENV NEXT_PUBLIC_WEB_SEARCH_ENABLED=$NEXT_PUBLIC_WEB_SEARCH_ENABLED
ENV SERP_API_KEY=$SERP_API_KEY
ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENV SKIP_ENV_VALIDATION=$SKIP_ENV_VALIDATION

WORKDIR /app
# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Copy the rest of the application code
COPY . .

# Prevent Husky errors by disabling the `prepare` script
RUN npm pkg set scripts.prepare="exit 0"

# set npm registry
RUN npm config set registry 'https://registry.npmmirror.com/'

RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn install; \
  fi




ENTRYPOINT ["sh", "entrypoint.sh"]

# Next.js collects completely anonymous telemetry data about general usage. Learn more here: https://nextjs.org/telemetry
# Uncomment the following line to disable telemetry at run time
# ENV NEXT_TELEMETRY_DISABLED 1

# Note: Don't expose ports here, Compose will handle that for us

# Start Next.js in development mode based on the preferred package manager
CMD \
  if [ -f yarn.lock ]; then yarn dev; \
  elif [ -f package-lock.json ]; then npm run dev; \
  elif [ -f pnpm-lock.yaml ]; then pnpm dev; \
  else yarn dev; \
  fi
