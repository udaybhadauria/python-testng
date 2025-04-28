#!/bin/bash

# Colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔵 Starting Tests...${NC}"

# Clean old reports if exist
echo "🧹 Cleaning old reports..."
rm -rf reports/*
rm -rf htmlcov/*

# Run Pytest with HTML and Coverage
echo "🧪 Running pytest..."
pytest --html=reports/report.html --self-contained-html --cov=app --cov-report=html

# Check if pytest succeeded
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Tests Passed Successfully!${NC}"
else
    echo -e "${RED}❌ Tests Failed! Check reports for details.${NC}"
    exit 1
fi

echo -e "${GREEN}📄 HTML Report generated at: reports/report.html${NC}"
echo -e "${GREEN}📈 Coverage Report generated at: htmlcov/index.html${NC}"
