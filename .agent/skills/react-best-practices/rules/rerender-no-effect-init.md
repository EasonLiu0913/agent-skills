---
title: Avoid setState in useEffect for Initialization
impact: HIGH
impactDescription: causes "Calling setState synchronously within an effect can trigger cascading renders" error in React 18+ Strict Mode
tags: react, hooks, useEffect, useState, initialization, cascading-renders, anti-pattern
---

## 避免在 useEffect 中使用 setState 進行初始化

在 useEffect 中呼叫 setState 來設定初始值會導致 React 18+ Strict Mode 下出現 "Calling setState synchronously within an effect can trigger cascading renders" 錯誤，並造成不必要的二次渲染。

### 問題說明

當你需要從 localStorage、計算結果或其他同步資料來源初始化 state 時，不應該使用 useEffect：

**錯誤寫法 (Anti-Pattern):**

```jsx
function ProductDesignProvider({ productId, product }) {
  const [uploadedDesigns, setUploadedDesigns] = useState({}) // ← 空初始值

  useEffect(() => {
    const savedLogo = localStorage.getItem(LOGO_STORAGE_KEY)
    const savedDesign = localStorage.getItem(getProductDesignKey(productId))
    
    if (savedLogo && savedDesign) {
      const designData = JSON.parse(savedDesign)
      setUploadedDesigns(designData) // ❌ 在 effect 中呼叫 setState
    }
  }, [productId])
  
  return <Context.Provider value={uploadedDesigns}>...</Context.Provider>
}
```

**問題：**
1. React 18 Strict Mode 會報錯：`Calling setState synchronously within an effect can trigger cascading renders`
2. 造成兩次渲染：首次渲染（空物件）→ effect 執行 → setState → 二次渲染
3. 可能產生 UI 閃爍

### 解決方案：使用 Lazy Initialization

將初始化邏輯抽取為獨立函式，並傳入 `useState` 作為 lazy initializer：

**正確寫法:**

```jsx
// 抽取為獨立的純函式
function computeInitialDesigns(productId, product) {
  // SSR 安全性檢查
  if (typeof window === 'undefined') {
    return {}
  }

  const savedLogo = localStorage.getItem(LOGO_STORAGE_KEY)
  const savedDesign = localStorage.getItem(getProductDesignKey(productId))

  if (!savedLogo || !product?.logoPosition?.length) {
    return {}
  }

  if (savedDesign) {
    try {
      const designData = JSON.parse(savedDesign)
      // ... 處理邏輯
      return designData
    } catch (e) {
      console.error('Failed to parse saved design:', e)
    }
  }

  return {}
}

function ProductDesignProvider({ productId, product }) {
  // ✅ 使用 lazy initialization - 傳入函式而非值
  const [uploadedDesigns, setUploadedDesigns] = useState(
    () => computeInitialDesigns(productId, product)
  )
  
  return <Context.Provider value={uploadedDesigns}>...</Context.Provider>
}
```

### 執行流程比較

```
【useEffect 作法 - 錯誤】
首次渲染 → DOM 更新 → useEffect 執行 → setState → 二次渲染 → DOM 更新
    ↑                                        ↑
  空物件 {}                              真實資料

【Lazy Initialization - 正確】
首次渲染（同時計算初始值）→ DOM 更新
    ↑
  真實資料（一步到位）
```

### 何時使用 useEffect vs Lazy Initialization

| 情境 | 使用方式 |
|------|----------|
| 從 localStorage/sessionStorage 讀取 | ✅ Lazy Initialization |
| 同步計算初始值 | ✅ Lazy Initialization |
| API 呼叫（真正的非同步） | useEffect + setState |
| 訂閱事件監聽器 | useEffect |
| props/state 變化後重新計算 | useEffect 或 useMemo |

### 重要提醒

1. **SSR 安全性**：在 lazy initializer 中加入 `typeof window === 'undefined'` 檢查
2. **純函式**：將計算邏輯抽取為獨立函式，提高可測試性
3. **關聯規則**：參考 `rerender-lazy-state-init.md` 了解效能優化面向

### 參考

- [React 18 Strict Mode 變更](https://react.dev/blog/2022/03/29/react-v18#new-strict-mode-behaviors)
- [useState lazy initialization](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)
