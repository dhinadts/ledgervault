---
name: Bharat Ledger System
colors:
  surface: '#fbf8ff'
  surface-dim: '#dbd9e1'
  surface-bright: '#fbf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2fb'
  surface-container: '#efecf5'
  surface-container-high: '#eae7ef'
  surface-container-highest: '#e4e1ea'
  on-surface: '#1b1b21'
  on-surface-variant: '#454652'
  inverse-surface: '#303036'
  inverse-on-surface: '#f2eff8'
  outline: '#767683'
  outline-variant: '#c6c5d4'
  surface-tint: '#4c56af'
  primary: '#000666'
  on-primary: '#ffffff'
  primary-container: '#1a237e'
  on-primary-container: '#8690ee'
  inverse-primary: '#bdc2ff'
  secondary: '#1b6d24'
  on-secondary: '#ffffff'
  secondary-container: '#a0f399'
  on-secondary-container: '#217128'
  tertiary: '#400003'
  on-tertiary: '#ffffff'
  tertiary-container: '#670007'
  on-tertiary-container: '#ff635a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000767'
  on-primary-fixed-variant: '#343d96'
  secondary-fixed: '#a3f69c'
  secondary-fixed-dim: '#88d982'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005312'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ac'
  on-tertiary-fixed: '#410003'
  on-tertiary-fixed-variant: '#93000e'
  background: '#fbf8ff'
  on-background: '#1b1b21'
  surface-variant: '#e4e1ea'
typography:
  display-lg:
    fontFamily: IBM Plex Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: IBM Plex Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  data-tabular:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  table-cell-padding: 12px 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is engineered for the precision-oriented landscape of Indian Small Scale Industries (SSI). The brand personality is rooted in **Reliability, Authority, and Localized Utility**. It balances the rigor of traditional Indian accounting (Munimji-style accuracy) with the efficiency of modern SaaS interfaces.

The chosen style is **Corporate / Modern** with a focus on **Data Density**. Unlike consumer fintech, this system prioritizes information over aesthetics, utilizing high-contrast tabular layouts, clear structural borders, and a logical hierarchy that minimizes cognitive load during long periods of data entry. The emotional response should be one of "Stability"—the user must feel that their financial compliance and records are secure and professionally managed.

## Colors

The palette is functional and compliant with standard financial mental models in the Indian context.

- **Primary Deep Navy (#1A237E):** Used for navigation, primary action buttons, and header elements to convey institutional trust and authority.
- **Emerald Green (#2E7D32):** Reserved exclusively for positive cash flow, credits, and profit indicators. This high-contrast green ensures "Gains" are immediately identifiable.
- **Crimson Red (#C62828):** Reserved for debits, losses, and critical alerts. It serves as a visual warning for out-of-balance entries.
- **Soft Slate Grey (#F5F7FA):** The foundation for the background to reduce eye strain during extended audit sessions.
- **Surface & Border:** Pure white is used for data containers (cards/tables) to contrast against the slate background, while a defined mid-grey border (#D1D5DB) ensures clear separation between ledger columns.

## Typography

Typography in this design system is optimized for **legibility of numerical strings**. 

- **Primary Face:** **Inter** is used for all body text and data inputs due to its exceptional performance in small sizes and its tabular numeric properties.
- **Secondary Face:** **IBM Plex Sans** is utilized for headers to provide a subtle industrial, structured feel that aligns with the "Small Scale Industry" theme.
- **Financial Formatting:** All currency values must be preceded by the **Indian Rupee symbol (₹)**. For tabular data, use `tnum` (tabular numbers) to ensure decimal points align vertically, facilitating easier visual audits of balance sheets.
- **Indian Accounting Context:** Labels for "Dr" (Debit) and "Cr" (Credit) should use `label-caps` for maximum distinction.

## Layout & Spacing

The design system employs a **Fixed-Fluid Hybrid Grid**. The sidebar and navigation remain fixed, while the primary ledger area fluidly expands to maximize horizontal real estate—critical for multi-column balance sheets.

- **Grid:** A 12-column grid with 16px gutters is used for dashboard layouts.
- **Density:** To accommodate the heavy data requirements of Indian accounting, vertical spacing is tight but intentional. Tables use a "Comfortable-Compact" cell padding (12px vertical) to ensure high row visibility without sacrificing readability.
- **Breakpoints:**
  - **Desktop (1280px+):** Full multi-pane ledger view.
  - **Tablet (768px - 1279px):** Condensed columns; horizontal scrolling enabled for wide tables.
  - **Mobile (<767px):** Cards replace table rows for individual entry viewing; specialized "Add Entry" speed-dials.

## Elevation & Depth

To maintain a professional and "flat" institutional feel, this design system avoids heavy shadows. 

- **Low-Contrast Outlines:** The primary method for defining hierarchy. Cards and containers use 1px solid borders (#D1D5DB).
- **Surface Tiers:** Background is #F5F7FA, while active workspaces (Ledgers, Form Fields) are #FFFFFF.
- **Subtle Depth:** A single, soft elevation level is used for "Floating" elements like dropdown menus or active modals: `0px 4px 12px rgba(0, 0, 0, 0.08)`.
- **Active State:** Hovering over a ledger row applies a very subtle tint of Navy (#1A237E at 4% opacity) to provide a visual "track" for the eye.

## Shapes

The shape language is **Conservative and Structured**. 

- **Radii:** A standard 0.25rem (4px) radius is applied to buttons, input fields, and containers. This "Soft" setting maintains a modern look while appearing more precise and "engineered" than pill-shaped consumer apps.
- **Inputs:** Square-ish corners emphasize the "Form" and "Document" nature of the system.
- **Icons:** Use 2px stroke weight with slight corner rounding to match the UI's geometry.

## Components

- **Buttons:**
  - **Primary:** Solid #1A237E with white text. High contrast for "Save Ledger" or "Generate Report".
  - **Secondary:** Outlined with #1A237E. For "Export to Excel" or "Print".
  - **Action-Specific:** Emerald Green for "Receive Payment" and Crimson Red for "Make Payment".
- **Data Tables (The Core Component):** 
  - Headers must be sticky with a #F5F7FA background.
  - Alternate row striping is not used; instead, use 1px horizontal dividers between rows.
  - Column alignment: Text to the left, Currency/Numbers to the right.
- **Status Chips:** Small, semi-rounded indicators for "Reconciled", "Pending", or "Overdue". Use high-tint backgrounds (10% opacity of the base color) with full-strength text.
- **Input Fields:** Labeled with clear instructions. Use a distinct "Focus" state with a 2px Deep Navy border. 
- **The "Rupee" Input:** A specialized field with a fixed (₹) prefix that cannot be deleted, ensuring all data entry follows the national standard.
- **Balance Cards:** Large-format cards at the top of ledgers showing "Current Balance", "Total Payables", and "Total Receivables" using the primary/green/red color logic.