# Configuration

What are the defaults, and who decided they were safe.

## What to Find

- Default credentials or secrets
- Insecure defaults (permissive CORS, disabled auth, debug mode)
- Missing security headers/controls
- Development settings in production paths
- Hardcoded secrets or API keys

## How to Look

Every default configuration is a bet that nobody will test the assumption. Check what happens when the application starts with zero configuration. Are the defaults safe? Or does someone have to know to change them?
