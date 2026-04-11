from typing import Optional

import gradio

from facefusion import metadata, translator

METADATA_BUTTON : Optional[gradio.Button] = None
WEBCAM_PAGE_LINK : Optional[gradio.HTML] = None


def render() -> None:
	global METADATA_BUTTON
	global WEBCAM_PAGE_LINK

	METADATA_BUTTON = gradio.Button(
		value = metadata.get('name') + ' ' + metadata.get('version'),
		variant = 'primary',
		link = metadata.get('url')
	)
	WEBCAM_PAGE_LINK = gradio.HTML(
		value = '<div style="text-align:center">'
		'<a href="/?ff_layout=webcam" target="_blank" rel="noopener noreferrer" '
		'style="display:inline-flex;align-items:center;justify-content:center;min-height:2rem;'
		'padding:0 0.75rem;border-radius:0.375rem;font-size:0.875rem;font-weight:400;'
		'border:1px solid var(--border-color-primary);text-decoration:none;color:inherit">'
		+ translator.get('about.webcam')
		+ '</a></div>'
	)
