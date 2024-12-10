import { getCollection } from 'astro:content'

export const getCategories = async () => {
	const posts = await getCollection('blog')
	const categories = new Set(posts.map((post) => post.data.category))
	// Convert the Set to an array and sort it alphabetically
  return Array.from(categories).sort((a, b) => a.localeCompare(b))
}

export const getPosts = async (max?: number) => {
	return (await getCollection('blog'))
		.filter((post) => !post.data.draft) // Exclude drafts
		.sort((a, b) => new Date(b.data.pubDate).getTime() - new Date(a.data.pubDate).getTime()) // Sort latest to oldest
		.slice(0, max); // Limit to max posts
};

export const getTags = async () => {
	const posts = await getCollection('blog')
	const tags = new Set(posts.map((post) => post.data.tags).flat())
	return Array.from(tags)
}

export const getPostByTag = async (tag: string) => {
	const posts = await getPosts()
	return posts.filter((post) => post.data.tags.includes(tag))
}

export const filterPostsByCategory = async (category: string) => {
	const posts = await getPosts()
	return posts.filter((post) => post.data.category.toLowerCase() === category)
}
