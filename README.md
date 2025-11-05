# Superset MCP: Organizing Dashboard Metadata

> How we use Superset MCP to keep complex dashboards structured, searchable, and easy to manage.

## Introduction

At Ponder, we first introduced Airflow MCP and its plugin to make working with DAGs and pipelines smoother. But along the way, we realized something: managing Superset dashboards and their metadata can be just as challenging—if not more so.

Take education as an example. Schools and educational institutions manage dozens—sometimes hundreds—of dashboards tracking everything from student performance and attendance to resource allocation and budget utilization. Multiple BI developers work constantly on these dashboards, making frequent updates and refinements so stakeholders can access the most current data to improve education and help pupils succeed. The result? A powerful ecosystem of insights—but also an overwhelming maze of metadata.

Questions like "Who changed the attendance dashboard last week?", "Which table powers our graduation rate metrics?", or "What's the data source behind this enrollment forecast?" can quickly become a time sink. And it's not just schools—any organization with a complex BI environment faces the same challenge.

That's why we built Superset MCP—so you can explore and manage Superset metadata through natural language, directly from your Claude code. No need to wrestle with the UI, no need to dig through layers of metadata. Just type your question, and get clear answers in plain language.

## 🚀 Quick Links

- 📦 [PyPI Package](https://pypi.org/project/superset-mcp-server/)
- 🐳 [Docker Hub Image](https://hub.docker.com/r/pondered/superset-mcp)
- 📖 [GitHub Repository](https://github.com/ponderedw/superset-mcp)

## Quickstart

### 1. Run Superset Locally

If you don't already have a Superset deployment but still want to try out Superset MCP, simply clone this repository and start it with Docker Compose:

```bash
git clone https://github.com/ponderedw/superset-mcp
cd superset-mcp
docker compose up
```

Once it's up, open your browser and visit:
- URL: http://localhost:8088/
- Username: `superset_admin`
- Password: `superset`

### 2. Using Superset MCP in Claude Desktop

1. Open Claude Desktop
2. Navigate to: **Settings → Developer → Edit Config**
3. Add the following entry to your MCP servers:

```json
{
  "mcpServers": {
    "superset": {
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "SUPERSET_API_URL",
        "-e",
        "SUPERSET_USERNAME",
        "-e",
        "SUPERSET_PASSWORD",
        "pondered/superset-mcp:latest"
      ],
      "command": "docker",
      "env": {
        "SUPERSET_API_URL": "http://host.docker.internal:8088",
        "SUPERSET_USERNAME": "superset_admin",
        "SUPERSET_PASSWORD": "superset"
      }
    }
  }
}
```

> **Note:** The Superset URL and credentials above match our local example environment.

4. Restart Claude Desktop

### 3. Using Superset MCP with LangChain

To integrate with LangChain:

1. Install our PyPI package:
```bash
pip install superset-mcp-server
```

2. Add the following MCP server configuration to your tools:

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
import os

mcps = {
    "SupersetMCP": {
        "command": "python",
        "args": ["-m", "superset_mcp_server.mcp_server"],
        "transport": "stdio",
        "env": {
            k: v for k, v in {
                "SUPERSET_API_URL": os.getenv("SUPERSET_API_URL"),
                "SUPERSET_USERNAME": os.getenv("SUPERSET_USERNAME"),
                "SUPERSET_PASSWORD": os.getenv("SUPERSET_PASSWORD"),
            }.items() if v is not None
        }
    }
}

client = MultiServerMCPClient(mcps)
mcp_tools = await client.get_tools()
```

Now you're ready to simply ask questions about your Superset instance in natural language—and let MCP handle the rest!

## 💬 Talking to Superset MCP

Once connected, you can ask natural language questions about your Superset environment:

### Example Queries

**Dashboard and Chart Overview:**
- "How many dashboards and charts do we have?"

**User Activity:**
- "Who are the most active users?"
- "Show me an activity timeline for this week"

**Data Lineage:**
- "What is the source table for Customer-Product Network?"
- "Which database tables power our revenue dashboard?"

**Change Tracking:**
- "When was the Revenue by Country chart last changed, and by whom?"
- "Who modified the attendance dashboard last week?"

### Setting Up Example Dashboards

To test Superset MCP with sample data:

1. Add a database connection using "postgres" as both host and database name
2. Use "superset" for both login and password
3. Create charts from the automatically ingested database tables
4. Organize them into dashboards (e.g., "E-commerce Performance Dashboard")
5. Don't forget to publish your dashboard!

## 🎯 Use Cases

### Education
- Track changes to student performance dashboards
- Identify data sources for graduation rate metrics
- Monitor who's updating attendance reports
- Manage resource allocation dashboard metadata

### Business Intelligence
- Navigate complex dashboard environments in healthcare, finance, retail, or manufacturing
- Delegate metadata queries to non-technical users
- Cut through metadata complexity with natural language queries
- Empower analysts, project managers, and department heads

## 🛠 Features

- **Natural Language Interface:** Ask questions in plain English
- **Metadata Management:** Track dashboard changes, creators, and modifications
- **Data Lineage:** Understand which tables power your charts and dashboards
- **User Activity:** Monitor who's been active in your BI environment
- **Cross-Platform:** Works with Claude Desktop and LangChain

## 🤝 Contributing

We're excited to see how the community will use Superset MCP—and we'd love your feedback. Try it out, share your ideas, and help us shape the next set of capabilities.

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

---

**Managing Metadata the Smart Way**

Superset MCP turns the often painful task of navigating dashboard metadata into a fast, intuitive conversation. Whether you're tracking changes to critical reports or understanding data lineage, you can now skip the clicks, menus, and manual searches. Just ask in plain language, and get precise, actionable answers.