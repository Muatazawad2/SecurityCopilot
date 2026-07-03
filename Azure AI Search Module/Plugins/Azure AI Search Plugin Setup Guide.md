# Azure AI Search Plugin — Setup Guide

**Developer**: Dr Muataz Awad

This guide is a **quick reference** for the Copilot plugin connection. Use it if you already have an Azure AI Search index configured and only need the field requirements, plugin configuration steps, and troubleshooting reference.

> For the full end-to-end setup from scratch, see the [Azure AI Search Complete Setup Guide](Azure%20AI%20Search%20Complete%20Setup%20Guide.md).

---

## Prerequisites

Before starting, ensure you have completed the following:

- ✅ **Azure AI Search service** (Basic tier or higher) created and managed identity enabled — see [Azure AI Search Complete Setup Guide](Azure%20AI%20Search%20Complete%20Setup%20Guide.md).
- An **Azure OpenAI service** with the `text-embedding-ada-002` model deployed (required for vectorization). Same region as the search service is ideal but not required — cross-region works with managed identity authentication.
- Access to **Microsoft Security Copilot** with permission to manage plugins.
- The content you want to index (policy documents, runbooks, SOC procedures, KQL libraries, etc.) available in a supported data source (Azure Blob Storage, SharePoint, SQL, or local upload).

---

## Phase 1 — Configure Your Azure AI Search Index

The Security Copilot integration requires your Azure AI Search index to meet specific field requirements. Use **Integrated Vectorization** (recommended) or manual index creation.

### Required Index Field Configuration

| Field Type | Requirement |
|---|---|
| **Text field** | Must be **searchable** — this is the body/content field Copilot searches |
| **Title field** | Must be **filterable** — this is the document title displayed in Copilot responses |
| **Vector field** | Must use **`text-embedding-ada-002`** embeddings — enables semantic search |

### Option A — Using Integrated Vectorization (Recommended)

Integrated Vectorization automates chunking, embedding generation, and index creation in a single wizard.

1. In the **Azure portal**, navigate to your **Azure AI Search service**.
2. Select **Import and vectorize data** from the Overview page.
3. Choose your **data source** (Azure Blob Storage, ADLS Gen2, SharePoint, or OneLake).
4. Connect to the data source and select the container or folder containing your documents.
5. On the **Vectorize your text** step, select **Azure OpenAI** and choose the deployment of `text-embedding-ada-002`.
6. On the **Advanced settings** step:
   - Verify that the index will have a **searchable text/chunk field**.
   - Verify that the index will have a **filterable title/metadata field**.
7. Name your index and click **Create** to start the indexer run.
8. Wait for the indexer to complete. Monitor progress under **Search management > Indexers**.

> **Reference**: [Quickstart: Integrated vectorization](https://learn.microsoft.com/en-us/azure/search/search-get-started-portal-import-vectors)

### Option B — Manual Index Creation

If you prefer manual control, create the index and indexer manually:

1. In your Azure AI Search service, go to **Indexes > + Add index**.
2. Define the index schema with at least these fields:

   ```json
   {
     "fields": [
       { "name": "id",      "type": "Edm.String",               "key": true,   "filterable": true  },
       { "name": "title",   "type": "Edm.String",               "searchable": true, "filterable": true  },
       { "name": "content", "type": "Edm.String",               "searchable": true  },
       { "name": "vector",  "type": "Collection(Edm.Single)",   "searchable": true,
         "dimensions": 1536, "vectorSearchProfile": "hnsw-profile" }
     ]
   }
   ```

3. Configure a **vectorizer** pointing to your `text-embedding-ada-002` Azure OpenAI deployment.
4. Create an **indexer** to populate the index from your data source.
5. Run the indexer and verify documents appear in the index.

### Verify Your Index Is Ready

Before connecting to Copilot, verify these three conditions in the Azure portal:

- [ ] The text/content field has **Searchable = Yes**
- [ ] The title/metadata field has **Filterable = Yes**
- [ ] The vector field uses **text-embedding-ada-002** (1536 dimensions)

---

## Phase 2 — Collect Your Azure AI Search Connection Details

From the Azure portal, gather the following values — you will need them when configuring the plugin in Copilot.

| Value | Where to Find It |
|---|---|
| **Search instance name** | Azure AI Search service > Overview > Name (the short name, e.g. `contoso-search`) |
| **Index name** | Azure AI Search service > Indexes > name of your index |
| **Vector field name** | Azure AI Search service > Indexes > your index > Fields tab > name of the vector field |
| **Text field name** | Azure AI Search service > Indexes > your index > Fields tab > name of the searchable text field |
| **Title field name** | Azure AI Search service > Indexes > your index > Fields tab > name of the filterable title field |
| **API key** | Azure AI Search service > **Security + networking** > **Keys** > copy the **Query key** (read-only) |

> **Security best practice**: Use a **query key** (read-only) rather than the admin key for Copilot. This limits the plugin to search operations only.

> **Tenant policy note**: If your tenant has `DisableLocalAuth: True` on the search service (keys disabled via portal), retrieve the query key via PowerShell instead:
> ```powershell
> $keys = Invoke-AzRestMethod -Method POST -Path "/subscriptions/{subscriptionId}/resourceGroups/{rg}/providers/Microsoft.Search/searchServices/{serviceName}/listQueryKeys?api-version=2024-06-01-preview"
> ($keys.Content | ConvertFrom-Json).value | Select-Object name, key
> ```

---

## Phase 3 — Connect Azure AI Search to Security Copilot

1. Open **Microsoft Security Copilot** and ensure you are authenticated.
2. In the prompt bar, select the **Sources** icon (the plug/sources icon to the left of the prompt bar).
3. In the **Manage sources** panel, navigate to **Microsoft** and locate **Azure AI search**.
4. Click **Set up** next to Azure AI search.
5. In the **Azure AI Search settings** dialog, fill in the following fields:

   | Field | Value |
   |---|---|
   | **Configuration level** | Select **Just for me** (personal) or **For everyone** (workspace-wide) |
   | **Azure AI Search instance** | The short name of your search service (e.g. `contoso-search`) |
   | **Index** | The name of your index (e.g. `security-kb-index`) |
   | **Vector** | The name of the vector field in your index (e.g. `vector`, `contentVector`) |
   | **Text** | The name of the text/content field (e.g. `content`, `chunk`) |
   | **Title** | The name of the title/metadata field (e.g. `title`, `metadata_storage_name`) |
   | **Value** | Your Azure AI Search API key (use a query key for least privilege) |

6. Click **Save** to apply the configuration.
7. Close the settings panel.

> **Note**: Security Copilot does not validate credentials at save time. If the connection details are incorrect, you will see an error when Copilot first attempts to invoke the plugin.

---

## Phase 4 — Test the Connection

Once the plugin is configured, test it with a simple prompt referencing **"Azure AI Search"** (required to invoke the plugin):

```
Search Azure AI Search for our incident response procedure for ransomware.
```

```
What does Azure AI Search say about our multi-factor authentication policy?
```

```
Using Azure AI Search, find any runbooks related to phishing investigation.
```

A successful response will include:
- A Copilot-generated summary of the matching content.
- Source document titles from your index listed below the response.

---

## Configuration Level — Personal vs. Workspace

| Level | Description | Who Sees It |
|---|---|---|
| **Just for me** | Plugin settings apply only to your account | Only you |
| **For everyone** | Plugin settings apply to the entire Copilot workspace | All users in the workspace |

Workspace-level configuration requires appropriate admin permissions in Security Copilot.

---

## Updating the Plugin (Switching Indexes)

Only one index can be connected at a time. To query a different index:

1. Return to **Sources > Microsoft > Azure AI search > Set up**.
2. Update the **Index**, **Vector**, **Text**, and **Title** fields to point to the new index.
3. Click **Save**.

---

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---|---|---|
| Plugin returns no results | API key is incorrect or index is empty | Verify the API key and confirm the indexer has run successfully |
| "Azure AI Search not found" error | Plugin not enabled or credentials invalid | Re-open settings and confirm all fields are populated correctly |
| Results are irrelevant | Vector field not configured or wrong field names | Verify field names match exactly as they appear in the Azure portal index schema |
| Plugin not invoked | Prompt does not mention "Azure AI Search" | Always include "Azure AI Search" explicitly in your prompts |
| Workspace-level save fails | Insufficient permissions | Ensure your account has workspace admin rights in Security Copilot |

---

## Known Limitations

- Only **one index** can be connected at a time.
- **Private link endpoints** are not supported.
- The plugin supports **hybrid search only** — indexes without a properly configured vector field are not supported.
- Document titles are displayed in responses but are **not hyperlinked**.
- Copilot reasons over **text content only** — tables, images, and other media types are not supported.

---

## References

- [Azure AI Search in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/plugin-azure-ai-search)
- [Connect your org knowledge base](https://learn.microsoft.com/en-us/copilot/security/connect-org-kb)
- [Quickstart: Integrated vectorization](https://learn.microsoft.com/en-us/azure/search/search-get-started-portal-import-vectors)
- [Azure AI Search service tiers](https://learn.microsoft.com/en-us/azure/search/search-sku-tier)

<!-- Repository maintenance marker -->
