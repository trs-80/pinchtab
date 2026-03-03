#!/usr/bin/env bash
set -euo pipefail

# doctor.sh - Verify development environment for pinchtab
# Checks requirements for Go backend and React dashboard development

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CRITICAL_FAIL=0
WARNINGS=0

echo -e "${BLUE}🩺 Pinchtab Doctor${NC}"
echo -e "${BLUE}Checking development environment...${NC}"
echo ""

# Critical check
check_critical() {
  local name="$1"
  local result="$2"
  
  if [ "$result" = "ok" ]; then
    echo -e "${GREEN}✅${NC} $name"
  else
    echo -e "${RED}❌${NC} $name"
    echo -e "   ${RED}$3${NC}"
    CRITICAL_FAIL=$((CRITICAL_FAIL + 1))
  fi
}

# Warning check
check_warning() {
  local name="$1"
  local result="$2"
  
  if [ "$result" = "ok" ]; then
    echo -e "${GREEN}✅${NC} $name"
  else
    echo -e "${YELLOW}⚠️${NC}  $name"
    echo -e "   ${YELLOW}$3${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
}

echo -e "${BLUE}━━━ Go Backend Requirements ━━━${NC}"
echo ""

# Go version (critical)
if command -v go &>/dev/null; then
  GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
  GO_MAJOR=$(echo "$GO_VERSION" | cut -d. -f1)
  GO_MINOR=$(echo "$GO_VERSION" | cut -d. -f2)
  
  if [ "$GO_MAJOR" -ge 1 ] && [ "$GO_MINOR" -ge 25 ]; then
    check_critical "Go $GO_VERSION" "ok"
  else
    check_critical "Go $GO_VERSION" "fail" "Go 1.25+ required. Install from https://go.dev/dl/"
  fi
else
  check_critical "Go" "fail" "Go not found. Install from https://go.dev/dl/"
fi

# golangci-lint (critical)
if command -v golangci-lint &>/dev/null; then
  LINT_VERSION=$(golangci-lint --version 2>/dev/null | head -1 | awk '{print $4}')
  check_critical "golangci-lint $LINT_VERSION" "ok"
else
  check_critical "golangci-lint" "fail" "Required for pre-commit checks. Install: brew install golangci-lint or go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
fi

# Git hooks (warning)
if [ -f ".git/hooks/pre-commit" ]; then
  check_warning "Git hooks installed" "ok"
else
  check_warning "Git hooks" "fail" "Run: ./scripts/install-hooks.sh"
fi

# Go modules (info)
if [ -f "go.mod" ]; then
  check_warning "go.mod present" "ok"
else
  check_warning "go.mod" "fail" "Run: go mod download"
fi

echo ""
echo -e "${BLUE}━━━ Dashboard Requirements (React/TypeScript) ━━━${NC}"
echo ""

# Check if dashboard directory exists
if [ -d "dashboard" ]; then
  # Node.js (critical for dashboard)
  if command -v node &>/dev/null; then
    NODE_VERSION=$(node -v | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
    
    if [ "$NODE_MAJOR" -ge 18 ]; then
      check_warning "Node.js $NODE_VERSION" "ok"
    else
      check_warning "Node.js $NODE_VERSION" "fail" "Node 18+ recommended. Current: $NODE_VERSION"
    fi
  else
    check_warning "Node.js" "fail" "Optional for dashboard. Install from https://nodejs.org"
  fi

  # Bun (warning)
  if command -v bun &>/dev/null; then
    BUN_VERSION=$(bun -v)
    check_warning "Bun $BUN_VERSION" "ok"
  else
    check_warning "Bun" "fail" "Optional for dashboard. Install: curl -fsSL https://bun.sh/install | bash"
  fi

  # Dashboard deps installed
  if [ -d "dashboard/node_modules" ]; then
    check_warning "Dashboard dependencies" "ok"
  else
    check_warning "Dashboard dependencies" "fail" "Run: cd dashboard && bun install (or npm install)"
  fi
else
  echo -e "${YELLOW}⚠️${NC}  Dashboard not found (optional)"
fi

echo ""
echo -e "${BLUE}━━━ Summary ━━━${NC}"
echo ""

if [ $CRITICAL_FAIL -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed! You're ready to develop.${NC}"
  exit 0
elif [ $CRITICAL_FAIL -eq 0 ]; then
  echo -e "${YELLOW}⚠️  $WARNINGS warning(s). Development is possible but some tools are missing.${NC}"
  exit 0
else
  echo -e "${RED}❌ $CRITICAL_FAIL critical issue(s). Fix these before developing.${NC}"
  [ $WARNINGS -gt 0 ] && echo -e "${YELLOW}⚠️  $WARNINGS warning(s).${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Fix critical issues above"
  echo "  2. Run: ./doctor.sh to verify"
  echo "  3. Run: ./setup.sh to complete setup"
  exit 1
fi
