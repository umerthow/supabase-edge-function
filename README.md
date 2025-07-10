# Users Edge Function API

A modern REST API built with Deno, Hono, and Supabase Edge Functions for user management.

## 🚀 Features

- **Fast & Lightweight**: Built with Deno and Hono framework
- **Edge Computing**: Deployed on Supabase Edge Functions
- **TypeScript**: Fully typed with TypeScript
- **Authentication**: JWT-based authentication middleware
- **CORS Enabled**: Cross-origin resource sharing configured
- **Environment Config**: Uses `@std/dotenv` for environment variables
- **Modern Architecture**: Clean separation of concerns with controllers, services, and routes

## 📁 Project Structure

```
users-edge-function/
├── supabase/
│   ├── config.toml
│   └── functions/
│       └── users-api/
│           ├── index.ts              # Main application entry point
│           ├── deno.json             # Deno configuration
│           ├── deno.lock             # Dependency lock file
│           ├── .env                  # Environment variables
│           ├── config/
│           │   └── env.ts            # Environment loader
│           ├── controllers/
│           │   └── user.controller.ts # User request handlers
│           ├── lib/
│           │   └── client.ts         # Supabase client setup
│           ├── middleware/
│           │   └── auth.middleware.ts # Authentication middleware
│           ├── routes/
│           │   └── user.routes.ts    # User route definitions
│           └── services/
│               └── user.service.ts   # User business logic
├── .github/
│   └── workflows/
│       └── deploy.yml               # GitHub Actions deployment
├── Dockerfile                       # Docker configuration
└── README.md                        # This file
```

## 🛠️ Prerequisites

- [Deno](https://deno.land/) v1.45.2 or later
- [Supabase CLI](https://supabase.com/docs/guides/cli) 
- A Supabase project

## 🔧 Environment Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd users-edge-function
   ```

2. **Configure environment variables**
   
   Create a `.env` file in `supabase/functions/users-api/`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   ```

3. **Install Supabase CLI** (if not already installed)
   ```bash
   npm install -g @supabase/cli
   ```

## 🚀 Local Development

### Option 1: Run with Deno directly (Recommended)

```bash
# Navigate to the function directory
cd supabase/functions/users-api

# Run the application
deno run --allow-net --allow-env --allow-read index.ts
```

The API will be available at: `http://localhost:9000`

### Option 2: Run with Supabase CLI

```bash
# Start Supabase locally (requires Docker)
supabase start

# Serve Edge Functions
supabase functions serve
```

The API will be available at: `http://127.0.0.1:54321/functions/v1/users-api`

## 📡 API Endpoints

### Health Check
- `GET /` - Welcome message
- `GET /health` - Health status

### User Management
- `GET /users` - Get all users
- `GET /users/:id` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user

### Example Requests

```bash
# Health check
curl http://localhost:9000/health

# Get all users
curl http://localhost:9000/users

# Create a user
curl -X POST http://localhost:9000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

## 🚀 Deployment

### Deploy to Supabase Edge Functions

1. **Login to Supabase**
   ```bash
   supabase login
   ```

2. **Link your project**
   ```bash
   supabase link --project-ref your-project-ref
   ```

3. **Deploy the function**
   ```bash
   supabase functions deploy users-api
   ```

4. **Set environment secrets** (if needed)
   ```bash
   supabase secrets set SUPABASE_URL=https://your-project.supabase.co
   supabase secrets set SUPABASE_ANON_KEY=your-anon-key
   ```

Your function will be live at:
`https://your-project.supabase.co/functions/v1/users-api`

### Deploy with GitHub Actions

The project includes a GitHub Actions workflow for automatic deployment:

1. **Set repository secrets:**
   - `SUPABASE_ACCESS_TOKEN`: Your Supabase access token
   - `SUPABASE_PROJECT_REF`: Your project reference ID

2. **Push to main branch** to trigger deployment

### Deploy with Docker

```bash
# Build the image
docker build -t users-edge-function .

# Run the container
docker run -p 9000:9000 --env-file .env users-edge-function
```

## 🔒 Authentication

The API uses JWT-based authentication middleware. Include your JWT token in the Authorization header:

```bash
curl -H "Authorization: Bearer your-jwt-token" http://localhost:9000/users
```

## 🧪 Testing

```bash
# Run with Deno's built-in test runner
deno test --allow-net --allow-env --allow-read

# Test specific endpoints
curl -X GET http://localhost:9000/health
curl -X GET http://localhost:9000/users
```

## 📦 Dependencies

- **Hono**: Fast web framework for edge computing
- **@supabase/supabase-js**: Supabase JavaScript client
- **@std/dotenv**: Environment variable loader
- **@supabase/functions-js**: Supabase Edge Functions runtime

## 🛡️ Security Features

- **CORS Protection**: Configured for secure cross-origin requests
- **Body Size Limits**: 1MB request body limit
- **JWT Authentication**: Secure token-based authentication
- **Environment Variables**: Sensitive data stored securely

## 🐳 Docker Support

The project includes a Dockerfile for containerized deployment:

```dockerfile
FROM denoland/deno:1.45.2
WORKDIR /app
COPY supabase/functions/users-api/ .
RUN deno cache index.ts
EXPOSE 9000
CMD ["deno", "run", "--allow-net", "--allow-env", "--allow-read", "index.ts"]
```

## 📝 Configuration

### Deno Configuration (`deno.json`)
```json
{
  "imports": {
    "hono": "jsr:@hono/hono@^4.6.11",
    "@supabase/supabase-js": "jsr:@supabase/supabase-js@^2.39.3",
    "@std/dotenv": "jsr:@std/dotenv@^0.225.2"
  }
}
```

### CORS Settings
- **Origin**: `*` (configure as needed for production)
- **Methods**: GET, POST, PUT, DELETE, OPTIONS
- **Headers**: Content-Type, Authorization

## 🔧 Troubleshooting

### Common Issues

1. **Connection refused**
   - Ensure environment variables are set correctly
   - Check if the Supabase project is active (not paused)

2. **Import errors**
   - Run `deno cache index.ts` to ensure dependencies are cached
   - Check network connectivity for JSR imports

3. **Authentication failures**
   - Verify JWT tokens are valid
   - Check Supabase project settings

### Debug Mode

Run with additional logging:
```bash
deno run --allow-net --allow-env --allow-read --log-level=debug index.ts
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📞 Support

For issues and questions:
- Create an issue on GitHub
- Check the [Supabase documentation](https://supabase.com/docs)
- Review the [Deno documentation](https://deno.land/manual)

---

**Built with ❤️ using Deno, Hono, and Supabase Edge Functions**
