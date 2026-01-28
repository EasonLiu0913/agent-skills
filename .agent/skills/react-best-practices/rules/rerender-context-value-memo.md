---
title: Memoize Context Provider Value
impact: MEDIUM
impactDescription: causes unnecessary re-renders of all context consumers when provider parent re-renders
tags: react, context, useMemo, performance, re-render
---

## Memoize Context Provider Value

當使用 React Context 時，必須用 `useMemo` 包裝 Provider 的 `value` 物件，否則每次 Provider 的父元件重新渲染時，所有使用該 Context 的子元件都會不必要地重新渲染。

### 問題說明

在 Context Provider 中直接創建物件作為 value，會導致每次渲染都產生新的物件引用：

**錯誤寫法 (Anti-Pattern):**

```jsx
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light')
  
  // ❌ 每次渲染都會創建新的物件，觸發所有 consumer 重新渲染
  const value = {
    theme,
    setTheme,
    toggleTheme: () => setTheme(t => t === 'light' ? 'dark' : 'light'),
  }
  
  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  )
}
```

**問題：**
1. 父元件因任何原因重新渲染 → `value` 是新物件 → 所有 consumer 重新渲染
2. 即使 `theme` 沒變，子元件也會重新渲染

### 解決方案：使用 useMemo

**正確寫法：**

```jsx
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light')
  
  // 使用 useCallback 確保函數引用穩定
  const toggleTheme = useCallback(() => {
    setTheme(t => t === 'light' ? 'dark' : 'light')
  }, [])
  
  // ✅ 使用 useMemo 包裝 value，只有在依賴項改變時才創建新物件
  const value = useMemo(() => ({
    theme,
    setTheme,
    toggleTheme,
  }), [theme, toggleTheme])
  
  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  )
}
```

### 何時該使用 useMemo

| 情境 | 是否需要 useMemo |
|------|------------------|
| Context Provider 的 value 物件 | ✅ **必須** |
| 包含多個屬性的計算結果 | ✅ 建議 |
| 傳遞給 `React.memo` 元件的 props 物件 | ✅ 建議 |
| 簡單的 primitive 值 (string, number) | ❌ 不需要 |
| 只在單一元件內使用的物件 | ❌ 通常不需要 |
| 每次渲染都必須重新計算的值 | ❌ 不適合 |

### 何時不該過度使用 useMemo

> **警告**：不要對所有東西都使用 `useMemo`！

```jsx
// ❌ 過度優化 - 這樣反而有額外開銷
const simpleValue = useMemo(() => 'hello', [])
const count = useMemo(() => 1 + 1, [])

// ❌ 過度優化 - 只在本元件使用，沒有傳遞給子元件
function Component() {
  const localObject = useMemo(() => ({ x: 1 }), []) // 沒必要
  return <div>{localObject.x}</div>
}
```

### useMemo 的成本

- **記憶體成本**：需要額外儲存依賴項陣列和快取值
- **比較成本**：每次渲染都要比較依賴項
- **適用場景**：只有當「重新計算」或「造成子元件重新渲染」的成本 > useMemo 的成本時才值得

### 關聯規則

- `rerender-memo.md` - 元件層級的 memoization
- `rerender-functional-setstate.md` - 使用 functional setState 保持 callback 穩定

### 參考

- [React useMemo 文檔](https://react.dev/reference/react/useMemo)
- [When to useMemo and useCallback](https://kentcdodds.com/blog/usememo-and-usecallback)
